class ArchivesSpaceService < Sinatra::Base

  include ReportHelper::ResponseHelpers

  Endpoint.get("/repositories/:repo_id/reports/nla_valuation_required")
  .description("Report on accessions where valuations are required")
  .params(ReportHelper.report_formats,
          ["repo_id", :repo_id])
  .permissions([])
  .returns([200, "report"]) \
      do
    report_response(AccValuationRequiredReport.new(params), params[:format])
  end


  Endpoint.get("/repositories/:repo_id/reports/nla_valuation_completed")
  .description("Report on accessions where valuations are completed")
  .params(ReportHelper.report_formats,
          ["repo_id", :repo_id])
  .permissions([])
  .returns([200, "report"]) \
      do
    report_response(AccValuationCompletedReport.new(params), params[:format])
  end


  Endpoint.get("/repositories/:repo_id/reports/nla_work_plan_development")
  .description("Work Plan Development report")
  .params(ReportHelper.report_formats,
          ["repo_id", :repo_id])
  .permissions([])
  .returns([200, "report"]) \
      do
    report_response(WorkPlanDevelopmentReport.new(params), params[:format])
  end


end