from cyclarity_sdk.expert_builder import Runnable, BaseResultsModel
import time
from cyclarity_sdk.sdk_models.findings import PTFinding
import cyclarity_sdk.sdk_models.findings.types as PTFindingTypes


class MyRunResult(BaseResultsModel):
    res: str = ""


class MyRunnable(Runnable[MyRunResult]):
    input_int: int = 100

    def setup(self):
        self.logger.info("SETUP before running")
        self.platform_api.send_test_report_description("My test description")

    def run(self, *args, **kwargs):
        self.logger.info("RUNNING")
        res = 0
        for percentage in range(101):
            self.platform_api.report_test_progress(percentage=percentage)
            time.sleep(0.01)
        return MyRunResult(res=f"{res}")

    def teardown(self, exception_type=None, exception_value=None, traceback=None):
        self.logger.info("TEARDOWN after run function")
        my_finding=PTFinding(topic='My finding',
                             status=PTFindingTypes.FindingStatus.FINISHED,
                             type=PTFindingTypes.FindingType.FINDING,
                             assessment_category=PTFindingTypes.AssessmentCategory.FUNCTIONAL_TEST,
                             assessment_technique=PTFindingTypes.AssessmentTechnique.OTHER_EXPLORATION,
                             purpose='Runnable example',
                             description='This is a PTFinding Description runnable example')
        self.platform_api.send_finding(my_finding)