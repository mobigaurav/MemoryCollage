from mangum import Mangum

from mb_api.main import app

lambda_handler = Mangum(app, lifespan="off")
