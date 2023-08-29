import json, sys
from traceback import format_exc

# logs the exception to stderr as a JSON object and also to sentry
def log_exception(e):
    print(
        json.dumps({
            "message": str(e),
            "traceback": format_exc().splitlines()
        }), file=sys.stderr)