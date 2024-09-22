from cyclarity_sdk.expert_builder import Runnable, BaseResultsModel
from cyclarity_sdk.sdk_models import ExecutionStatus
import time


class MyRunResult(BaseResultsModel):
    res: str = ""


class MyRun(Runnable[MyRunResult]):
    input_int: int = 100

    def setup(self):
        self.logger.info("SETUP")
        self.platform_api.send_test_report_description("My runnable description!")

    def run(self, *args, **kwargs):
        res = 0
        for i in range(self.input_int):
            self.logger.info(i)
            self.platform_api.send_execution_state(i, ExecutionStatus.RUNNING, "")
            time.sleep(0.5)
            res += i
        return MyRunResult(res=f"{res}")

    def teardown(self, exception_type=None, exception_value=None, traceback=None):
        self.logger.info("TEARDOWN")

