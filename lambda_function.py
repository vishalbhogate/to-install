import logging
from githubbot import MatchEvent
import sys
from log import log_exception

def lambda_handler(event, context):
    try:
        MatchEvent().filterEvent()
      
        return {
            "success": True,
            "message": "ok"
        }

    except Exception as e :
        log_exception(e)
        return {
            "success": False,
            "message": str(e)
        }

# entrypoint for running directly, outside of the lambda context
if __name__ == "__main__":
    logging_level = logging.DEBUG if 'debug' else logging.INFO
    resp=lambda_handler({},{})
    if not resp.get("success", False):
        logging.error(resp.get("message", "failed"))
        sys.exit(1)