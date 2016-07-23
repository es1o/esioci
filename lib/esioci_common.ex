defmodule EsioCi.Common do
  @moduledoc """
  This is a EsioCi.Common module
  Place all common funcion here
  """
  require Logger

  def run(cmd, dir \\ "/tmp") do
    cmd_list = String.split(cmd)
    {stdout, exit_code} = System.cmd(hd(cmd_list), tl(cmd_list), stderr_to_stdout: true, cd: dir)
    if exit_code != 0 do
      Logger.error stdout
      raise "Command #{cmd} exit code: #{exit_code}"
    else
      Logger.info stdout
      :ok
    end
  end

  def change_bld_status(b_id, status) do
    build = EsioCi.Repo.get(EsioCi.Build, b_id)
    build = Ecto.Changeset.change build, state: status
    Logger.info "update"
    EsioCi.Repo.update! build
    
  end
end