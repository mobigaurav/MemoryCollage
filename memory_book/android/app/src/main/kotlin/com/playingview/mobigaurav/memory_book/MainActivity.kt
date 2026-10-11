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
import android.media.MediaMetadataRetriever
import android.media.MediaMuxer
import android.net.Uri
import android.os.Build
import android.view.Surface
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.media3.common.MediaItem
import androidx.media3.common.audio.AudioProcessor
import androidx.media3.common.util.UnstableApi
import androidx.media3.effect.Presentation
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.EditedMediaItemSequence
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.Transformer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
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
                            "preparePlayback" -> result.success(null)
                            "mixAudio" -> {
                                val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                                val video = args["videoPath"] as? String ?: error("videoPath")
                                val audio = args["audioPath"] as? String ?: error("audioPath")
                                result.success(muxAudio(video, audio))
                            }
                            "encodeHeic" -> result.success(call.argument<ByteArray>("bytes"))
                            "posterFrame" -> result.success(posterFrame(call.arguments()))
                            "editClip" -> {
                                val args = call.arguments
                                runOnUiThread {
                                    try {
                                        editClip(args, result)
                                    } catch (e: Exception) {
                                        result.error("encode", e.message, null)
                                    }
                                }
                            }
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
            decodeUpright(path)
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

    private fun decodeUpright(path: String): Bitmap? {
        val bmp = BitmapFactory.decodeFile(path) ?: return null
        val orientation = try {
            android.media.ExifInterface(path).getAttributeInt(
                android.media.ExifInterface.TAG_ORIENTATION,
                android.media.ExifInterface.ORIENTATION_NORMAL,
            )
        } catch (_: Exception) {
            return bmp
        }
        val degrees = when (orientation) {
            android.media.ExifInterface.ORIENTATION_ROTATE_90 -> 90f
            android.media.ExifInterface.ORIENTATION_ROTATE_180 -> 180f
            android.media.ExifInterface.ORIENTATION_ROTATE_270 -> 270f
            else -> return bmp
        }
        val matrix = android.graphics.Matrix().apply { postRotate(degrees) }
        val rotated = Bitmap.createBitmap(bmp, 0, 0, bmp.width, bmp.height, matrix, true)
        if (rotated != bmp) bmp.recycle()
        return rotated
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

    private fun posterFrame(raw: Any?): ByteArray {
        val args = raw as? Map<*, *> ?: error("poster")
        val path = args["path"] as? String ?: error("path")
        val atMs = (args["atMs"] as? Number)?.toLong() ?: 0L
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(path)
            val frame = retriever.getFrameAtTime(
                atMs * 1000,
                MediaMetadataRetriever.OPTION_CLOSEST,
            ) ?: error("Could not read a frame from this reel.")
            val stream = ByteArrayOutputStream()
            frame.compress(Bitmap.CompressFormat.JPEG, 86, stream)
            frame.recycle()
            return stream.toByteArray()
        } finally {
            retriever.release()
        }
    }

    @OptIn(UnstableApi::class)
    private fun editClip(raw: Any?, result: MethodChannel.Result) {
        val args = raw as? Map<*, *> ?: error("edit")
        val output = args["outputPath"] as? String ?: error("outputPath")
        val aspect = args["aspect"] as? String ?: "original"
        val mute = args["mute"] as? Boolean ?: false
        val clips = args["clips"] as? List<*> ?: error("clips")
        val items = clips.map { item ->
            val map = item as? Map<*, *> ?: error("clip")
            val path = map["path"] as? String ?: error("path")
            val start = (map["startMs"] as? Number)?.toLong() ?: 0L
            val end = (map["endMs"] as? Number)?.toLong() ?: 0L
            val clipping = MediaItem.ClippingConfiguration.Builder()
                .setStartPositionMs(start.coerceAtLeast(0))
                .apply { if (end > start) setEndPositionMs(end) }
                .build()
            val media = MediaItem.Builder()
                .setUri(Uri.fromFile(File(path)))
                .setClippingConfiguration(clipping)
                .build()
            val effects = when (aspect) {
                "9:16" -> crop(9f / 16f)
                "1:1" -> crop(1f)
                "4:5" -> crop(4f / 5f)
                "16:9" -> crop(16f / 9f)
                else -> Effects.EMPTY
            }
            EditedMediaItem.Builder(media)
                .setRemoveAudio(mute)
                .setEffects(effects)
                .build()
        }
        if (items.isEmpty()) error("Choose a reel to edit.")
        val sequence = if (mute) {
            EditedMediaItemSequence.withVideoFrom(items)
        } else {
            EditedMediaItemSequence.withAudioAndVideoFrom(items)
        }
        val composition = Composition.Builder(sequence)
            .setHdrMode(Composition.HDR_MODE_TONE_MAP_HDR_TO_SDR_USING_OPEN_GL)
            .build()
        val out = File(output)
        out.parentFile?.mkdirs()
        if (out.exists()) out.delete()
        var finished = false
        val transformer = Transformer.Builder(this)
            .addListener(object : Transformer.Listener {
                override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                    if (finished) return
                    finished = true
                    result.success(output)
                }

                override fun onError(
                    composition: Composition,
                    exportResult: ExportResult,
                    exportException: ExportException,
                ) {
                    if (finished) return
                    finished = true
                    result.error("encode", exportException.message, null)
                }
            })
            .build()
        transformer.start(composition, output)
    }

    @OptIn(UnstableApi::class)
    private fun crop(aspect: Float): Effects {
        return Effects(
            emptyList<AudioProcessor>(),
            listOf(
                Presentation.createForAspectRatio(
                    aspect,
                    Presentation.LAYOUT_SCALE_TO_FIT_WITH_CROP,
                ),
            ),
        )
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
