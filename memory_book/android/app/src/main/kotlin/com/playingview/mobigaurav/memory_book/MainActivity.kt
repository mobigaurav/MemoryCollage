package com.playingview.mobigaurav.memory_book

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import android.os.Build
import android.view.Surface
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "memory_book/video_encoder")
            .setMethodCallHandler { call, result ->
                thread {
                    try {
                        when (call.method) {
                            "encodeFrames" -> result.success(encode(call.arguments()))
                            "encodeSlideshow" -> result.success(encode(call.arguments(), slideshow = true))
                            "encodeHeic" -> result.success(call.argument<ByteArray>("bytes"))
                            else -> result.notImplemented()
                        }
                    } catch (e: Exception) {
                        result.error("encode", e.message, null)
                    }
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "memory_book/notify")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "request" -> {
                        ensureNotifyPermission()
                        result.success(null)
                    }
                    "show" -> {
                        val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                        showReady(
                            args["title"] as? String ?: "Memory Book",
                            args["body"] as? String ?: "Your reel is ready.",
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun encode(args: Map<String, Any>?, slideshow: Boolean = false): String {
        val images = (args?.get("frames") ?: args?.get("images")) as? List<*> ?: emptyList<Any>()
        val output = args?.get("outputPath") as? String ?: error("outputPath")
        val width = ((args?.get("width") as? Int) ?: 1080) / 2 * 2
        val height = ((args?.get("height") as? Int) ?: 1920) / 2 * 2
        val fps = if (slideshow) 24 else ((args?.get("fps") as? Int) ?: 12)
        val seconds = (args?.get("secondsPerSlide") as? Double) ?: 3.0
        val hold = if (slideshow) (seconds * fps).toInt().coerceAtLeast(1) else 1
        val transition = args?.get("transition") as? String ?: "none"
        val filter = args?.get("filter") as? String ?: "none"
        val audio = args?.get("audioPath") as? String
        val transFrames = if (!slideshow || transition == "none") 0 else 8
        File(output).parentFile?.mkdirs()
        if (File(output).exists()) File(output).delete()

        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height)
        format.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface)
        format.setInteger(MediaFormat.KEY_BIT_RATE, 6_000_000)
        format.setInteger(MediaFormat.KEY_FRAME_RATE, fps)
        format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
        val codec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
        codec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        val surface: Surface = codec.createInputSurface()
        codec.start()
        val muxer = MediaMuxer(output, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        var track = -1
        var muxerStarted = false
        val bufferInfo = MediaCodec.BufferInfo()

        fun drain(end: Boolean) {
            if (end) codec.signalEndOfInputStream()
            while (true) {
                val outIndex = codec.dequeueOutputBuffer(bufferInfo, 10_000)
                when {
                    outIndex == MediaCodec.INFO_TRY_AGAIN_LATER -> if (!end) return else continue
                    outIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        track = muxer.addTrack(codec.outputFormat)
                        muxer.start()
                        muxerStarted = true
                    }
                    outIndex >= 0 -> {
                        val encoded = codec.getOutputBuffer(outIndex) ?: continue
                        if (bufferInfo.size > 0 && muxerStarted) {
                            encoded.position(bufferInfo.offset)
                            encoded.limit(bufferInfo.offset + bufferInfo.size)
                            muxer.writeSampleData(track, encoded, bufferInfo)
                        }
                        codec.releaseOutputBuffer(outIndex, false)
                        if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) return
                    }
                }
            }
        }

        fun post(bitmap: Bitmap) {
            val sc = surface.lockCanvas(null)
            sc.drawBitmap(bitmap, 0f, 0f, null)
            surface.unlockCanvasAndPost(sc)
            drain(false)
        }

        val bitmaps = images.mapNotNull { raw ->
            val path = raw as? String ?: return@mapNotNull null
            BitmapFactory.decodeFile(path)
        }
        for (i in bitmaps.indices) {
            val still = compose(bitmaps[i], null, 0f, "none", width, height, filter)
            repeat(hold) { post(still) }
            still.recycle()
            if (transFrames > 0 && i + 1 < bitmaps.size) {
                for (step in 1..transFrames) {
                    val t = step / transFrames.toFloat()
                    val frame = compose(bitmaps[i], bitmaps[i + 1], t, transition, width, height, filter)
                    post(frame)
                    frame.recycle()
                }
            }
        }
        bitmaps.forEach { it.recycle() }
        drain(true)
        codec.stop()
        codec.release()
        surface.release()
        if (muxerStarted) muxer.stop()
        muxer.release()
        if (!audio.isNullOrEmpty() && File(audio).exists()) {
            return muxAudio(output, audio)
        }
        return output
    }

    private fun compose(
        from: Bitmap,
        next: Bitmap?,
        t: Float,
        type: String,
        width: Int,
        height: Int,
        filter: String,
    ): Bitmap {
        val out = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(out)
        canvas.drawColor(Color.parseColor("#F6EFE3"))
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
        paint.colorFilter = colorFilter(filter)
        fun dest(bmp: Bitmap): RectF = fitF(bmp.width, bmp.height, width, height)
        when (type) {
            "slide" -> {
                paint.alpha = 255
                canvas.drawBitmap(from, null, dest(from), paint)
                if (next != null) {
                    val d = dest(next)
                    d.offset(d.width() * (1 - t), 0f)
                    canvas.drawBitmap(next, null, d, paint)
                }
            }
            "zoom" -> {
                paint.alpha = (255 * (1 - t * 0.35f)).toInt()
                val a = dest(from)
                val grow = a.width() * 0.08f * t
                a.inset(-grow, -grow * a.height() / a.width())
                canvas.drawBitmap(from, null, a, paint)
                if (next != null) {
                    paint.alpha = (255 * t).toInt()
                    val b = dest(next)
                    val shrink = b.width() * 0.12f * (1 - t)
                    b.inset(shrink, shrink * b.height() / b.width())
                    canvas.drawBitmap(next, null, b, paint)
                }
            }
            "crossfade" -> {
                paint.alpha = (255 * (1 - t)).toInt()
                canvas.drawBitmap(from, null, dest(from), paint)
                if (next != null) {
                    paint.alpha = (255 * t).toInt()
                    canvas.drawBitmap(next, null, dest(next), paint)
                }
            }
            else -> {
                paint.alpha = 255
                canvas.drawBitmap(from, null, dest(from), paint)
            }
        }
        return out
    }

    private fun colorFilter(name: String): ColorMatrixColorFilter? {
        val m = ColorMatrix()
        when (name) {
            "sepia" -> m.set(
                floatArrayOf(
                    0.393f, 0.769f, 0.189f, 0f, 0f,
                    0.349f, 0.686f, 0.168f, 0f, 0f,
                    0.272f, 0.534f, 0.131f, 0f, 0f,
                    0f, 0f, 0f, 1f, 0f,
                ),
            )
            "noir" -> m.setSaturation(0f)
            "vignette" -> m.setScale(0.82f, 0.82f, 0.82f, 1f)
            "bloom" -> m.setScale(1.08f, 1.04f, 0.92f, 1f)
            "instant" -> m.setScale(1.1f, 0.95f, 0.85f, 1f)
            "comic" -> m.setSaturation(1.4f)
            "enhance" -> {
                m.setSaturation(1.15f)
                m.postConcat(ColorMatrix(floatArrayOf(
                    1.05f, 0f, 0f, 0f, 8f,
                    0f, 1.02f, 0f, 0f, 4f,
                    0f, 0f, 0.98f, 0f, 2f,
                    0f, 0f, 0f, 1f, 0f,
                )))
            }
            else -> return null
        }
        return ColorMatrixColorFilter(m)
    }

    private fun muxAudio(video: String, audio: String): String {
        return try {
            val out = video.replace(".mp4", "_m.mp4")
            if (File(out).exists()) File(out).delete()
            val videoExt = MediaExtractor().apply { setDataSource(video) }
            val audioExt = MediaExtractor().apply { setDataSource(audio) }
            val muxer = MediaMuxer(out, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
            var vIndex = 0
            while (vIndex < videoExt.trackCount &&
                videoExt.getTrackFormat(vIndex).getString(MediaFormat.KEY_MIME)?.startsWith("video/") != true
            ) {
                vIndex++
            }
            var aIndex = 0
            while (aIndex < audioExt.trackCount &&
                audioExt.getTrackFormat(aIndex).getString(MediaFormat.KEY_MIME)?.startsWith("audio/") != true
            ) {
                aIndex++
            }
            if (vIndex >= videoExt.trackCount || aIndex >= audioExt.trackCount) {
                videoExt.release()
                audioExt.release()
                muxer.release()
                return video
            }
            videoExt.selectTrack(vIndex)
            audioExt.selectTrack(aIndex)
            val vt = muxer.addTrack(videoExt.getTrackFormat(vIndex))
            val at = muxer.addTrack(audioExt.getTrackFormat(aIndex))
            muxer.start()
            copyTrack(videoExt, muxer, vt)
            copyTrack(audioExt, muxer, at)
            muxer.stop()
            muxer.release()
            videoExt.release()
            audioExt.release()
            out
        } catch (_: Exception) {
            video
        }
    }

    private fun copyTrack(extractor: MediaExtractor, muxer: MediaMuxer, track: Int) {
        val buffer = java.nio.ByteBuffer.allocate(1 shl 20)
        val info = MediaCodec.BufferInfo()
        while (true) {
            val size = extractor.readSampleData(buffer, 0)
            if (size < 0) break
            info.offset = 0
            info.size = size
            info.presentationTimeUs = extractor.sampleTime
            info.flags = extractor.sampleFlags
            muxer.writeSampleData(track, buffer, info)
            extractor.advance()
        }
    }

    private fun fitF(iw: Int, ih: Int, w: Int, h: Int): RectF {
        val input = iw.toFloat() / ih
        val output = w.toFloat() / h
        return if (input > output) {
            val nh = h.toFloat()
            val nw = h * input
            val x = (w - nw) / 2
            RectF(x, 0f, x + nw, nh)
        } else {
            val nw = w.toFloat()
            val nh = w / input
            val y = (h - nh) / 2
            RectF(0f, y, nw, y + nh)
        }
    }

    private fun fit(iw: Int, ih: Int, w: Int, h: Int): Rect {
        val f = fitF(iw, ih, w, h)
        return Rect(f.left.toInt(), f.top.toInt(), f.right.toInt(), f.bottom.toInt())
    }

    private fun ensureNotifyPermission() {
        if (Build.VERSION.SDK_INT >= 33 &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                91,
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "memory_book",
                "Exports",
                NotificationManager.IMPORTANCE_DEFAULT,
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun showReady(title: String, body: String) {
        ensureNotifyPermission()
        val notification = NotificationCompat.Builder(this, "memory_book")
            .setSmallIcon(android.R.drawable.ic_menu_gallery)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .build()
        if (Build.VERSION.SDK_INT < 33 ||
            ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            NotificationManagerCompat.from(this).notify(42, notification)
        }
    }
}
