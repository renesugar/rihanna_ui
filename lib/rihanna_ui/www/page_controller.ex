defmodule RihannaUI.WWW.PageController do
  use Raxx.Server

  require EEx
  require Ecto.Query, as: Query

  template = Path.join(__DIR__, "./home_page.html.eex")
  EEx.function_from_file(:defp, :overview, template, [:assigns])

  @impl Raxx.Server
  def handle_request(_request, _state) do
    response(:ok)
    |> set_header("content-type", "text/html")
    |> set_body(view(%{}))
  end

  def handle_request(%{method: :GET, path: []}, _) do
    jobs = Rihanna.Job
    |> RihannaUI.Repo.all()
    |> Enum.group_by(&(&1.state))
    enqueued = Enum.count(jobs["ready_to_run"] || [])
    in_progress = Enum.count(jobs["in_progress"] || [])
    failed = Enum.count(jobs["failed"] || [])

    render conn, "overview.html", enqueued: enqueued, in_progress: in_progress, failed: failed
  end

  def enqueued(conn, _params) do
    enqueued_jobs = Rihanna.Job
    |> Query.where(state: "ready_to_run")
    |> RihannaUI.Repo.all()

    render conn, "enqueued.html", jobs: enqueued_jobs
  end

  def in_progress(conn, _) do
    in_progress_jobs = Rihanna.Job
    |> Query.where(state: "in_progress")
    |> RihannaUI.Repo.all()

    render conn, "in_progress.html", jobs: in_progress_jobs
  end

  def failed(conn, _params) do
    failed_jobs = Rihanna.Job
    |> Query.where(state: "failed")
    |> RihannaUI.Repo.all()

    render conn, "failed.html", jobs: failed_jobs
  end
end