defmodule EsioCi.Builder do
  require Logger
  require Poison

  def build do
    receive do
      {sender, msg, build_id, type} ->
        case type do
          "gh" -> Logger.debug "GitHub"
                  status = parse_github(msg)
                            |> clone
                  Logger.info status
          _ -> try do
            Logger.debug "Processing build with id: #{build_id}"
            :random.seed(:os.timestamp()) 
            dst = "/tmp/build/#{:random.uniform(666)}"
            Logger.debug "Create directory #{dst}"
            File.mkdir_p(dst)
            Logger.debug "Receive message from #{inspect sender}"

            {scm, repo_address} = parse_bitbucket(msg)

            download_sources(scm, repo_address, dst)
            EsioCi.Common.change_bld_status(build_id, "RUNNING")
            case run_build(dst) do
              :ok -> EsioCi.Common.change_bld_status(build_id, "COMPLETED")
              _   -> EsioCi.Common.change_bld_status(build_id, "FAILED")
                
            end

          rescue
            e in RuntimeError -> e
            #Logger.error "Exception!"
          end
        end

    end
  end

  def parse_github(req_json) do
    git_url     = req_json.params["repository"]["git_url"]
    commit_sha  = req_json.params["head_commit"]["id"]
    repo_name   = req_json.params["repository"]["full_name"]
    Logger.debug "Repository url: #{git_url}"
    Logger.debug "Repository name: #{repo_name}"
    Logger.debug "Commit sha: #{commit_sha}"

    {:ok, git_url, repo_name, commit_sha}
  end

  def clone({ok, git_url, repo_name, commit_sha}) do
    cmd = "git clone #{git_url} /tmp/xxx"
    EsioCi.Common.run2(cmd, "/tmp")
  end

  defp download_sources(scm, repo_address, dst) do
    case scm do
       "git" -> clone_git(repo_address, dst)
       _ -> clone_git(repo_address, dst)
        
    end
  end

  defp clone_git(repo_address, dst) do
    cmd = "git clone #{repo_address} #{dst}"
    Logger.info "Cloning git repository #{repo_address} to #{dst}"
    EsioCi.Common.run(cmd, dst)
  end

  defp run_build(dst) do
    Logger.info "Run build"
    cmd = get_exec_from_yaml(dst)
    EsioCi.Common.run(cmd, dst)
  end

  defp get_exec_from_yaml(dst) do
    Logger.info "Parse build.yaml file"
    [yaml | _] = :yamerl_constr.file("#{dst}/esioci.yaml")
    [build | _] = :proplists.get_value('build', yaml)
    :proplists.get_value('exec', build) |> List.to_string

  end
  defp parse_bitbucket(req_json) do
    scm = req_json.params["repository"]["scm"]
    Logger.debug "Repository scm type: #{scm}"

    repo_address = "git@bitbucket.org:#{req_json.params["repository"]["full_name"]}.git"

    Logger.debug "Repository address: #{repo_address}"

    {scm, repo_address}
  end
end
