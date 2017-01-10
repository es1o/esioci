defmodule Esioci.Router.Test do
  require Poison
  import Ecto.Query, only: [from: 2]
  use ExUnit.Case, async: true
  use Plug.Test

  @opts EsioCi.Router.init([])

  test "returns hello world" do
    conn = conn(:get, "/")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "EsioCi app alpha"
  end

  test "can't create github build for nonexisting project" do
    conn = conn(:post, "/api/v1/esiononexistingproject/bld/gh")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "404: Project esiononexistingproject not found."
  end

  test "can't create bitbucket build for nonexisting project" do
    conn = conn(:post, "/api/v1/esiononexistingproject/bld/bb")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "404: Project esiononexistingproject not found."
  end

  test "get all builds" do
    q = from p in "projects",
      where: p.name == "test03-get-all-builds",
      select: p.id

    p_id = EsioCi.Repo.all(q)

    if Enum.count(p_id) != 0 do
      project_id = List.first(p_id)
      project = EsioCi.Repo.get(EsioCi.Project, project_id)
      EsioCi.Repo.delete!(project)
    end

    project = %EsioCi.Project{name: "test03-get-all-builds"}
    created_project = EsioCi.Repo.insert!(project)

    build = %EsioCi.Build{state: "COMPLETED", project_id: created_project.id}
    created_build = EsioCi.Repo.insert!(build)

    conn = conn(:get, "/api/v1/test03-get-all-builds/bld/all")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "[{\"updated_at\":\"#{NaiveDateTime.to_iso8601(created_build.updated_at)}\",\"state\":\"COMPLETED\",\"project\":{\"name\":\"test03-get-all-builds\",\"id\":#{created_project.id}},\"inserted_at\":\"#{NaiveDateTime.to_iso8601(created_build.inserted_at)}\",\"id\":#{created_build.id},\"artifacts_dir\":\"\"}]"
  end

  test "get last build status" do
    q = from p in "projects",
      where: p.name == "test02",
      select: p.id

    p_id = EsioCi.Repo.all(q)

    if Enum.count(p_id) == 0 do
      project = %EsioCi.Project{name: "test02"}
      created_project = EsioCi.Repo.insert!(project)
      project_id = created_project.id
    else
      project_id = List.first(p_id)
    end

    build = %EsioCi.Build{state: "CREATED-esio-last-build-status", project_id: project_id}
    created_build = EsioCi.Repo.insert!(build)

    conn = conn(:get, "/api/v1/test02/bld/last")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "[{\"updated_at\":\"#{NaiveDateTime.to_iso8601(created_build.updated_at)}\",\"state\":\"CREATED-esio-last-build-status\",\"project\":{\"name\":\"test02\",\"id\":#{project_id}},\"inserted_at\":\"#{NaiveDateTime.to_iso8601(created_build.inserted_at)}\",\"id\":#{created_build.id},\"artifacts_dir\":\"\"}]"
  end

  test "get build by id" do
    q = from p in "projects",
      where: p.name == "test02",
      select: p.id

    p_id = EsioCi.Repo.all(q)

    if Enum.count(p_id) == 0 do
      project = %EsioCi.Project{name: "test02"}
      created_project = EsioCi.Repo.insert!(project)
      project_id = created_project.id
    else
      project_id = List.first(p_id)
    end

    build = %EsioCi.Build{state: "CREATED-esio-build-by-id", project_id: project_id}
    created_build = EsioCi.Repo.insert!(build)

    conn = conn(:get, "/api/v1/test02/bld/#{created_build.id}")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "[{\"updated_at\":\"#{NaiveDateTime.to_iso8601(created_build.updated_at)}\",\"state\":\"CREATED-esio-build-by-id\",\"project\":{\"name\":\"test02\",\"id\":#{project_id}},\"inserted_at\":\"#{NaiveDateTime.to_iso8601(created_build.inserted_at)}\",\"id\":#{created_build.id},\"artifacts_dir\":\"\"}]"
  end

  test "get last build status from nonexisting project" do
    conn = conn(:get, "/api/v1/nonexisting-project/bld/last")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "404: Project nonexisting-project not found."
  end

  test "get project" do
    conn = conn(:get, "/api/v1/default")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "[{\"name\":\"default\",\"id\":1}]"
  end

  test "get project by id" do
    conn = conn(:get, "/api/v1/projects/1")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "[{\"name\":\"default\",\"id\":1}]"
  end

  test "get all projects" do
    project = %EsioCi.Project{name: "test_get_all_projects"}
              |> EsioCi.Repo.insert!
    conn = conn(:get, "/api/v1/projects/all")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    {:ok, json} = Poison.decode(conn.resp_body)
    assert Enum.count(json) > 1
    assert List.last(json) == %{"id" => 1, "name" => "default"}
  end

  test "get nonexisting project" do
    conn = conn(:get, "/api/v1/nonexisting-project")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "404: Project nonexisting-project not found."
  end

  test "returns 404" do
    conn = conn(:get, "/esioesioesio")

    conn = EsioCi.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "add build to DB and change status" do
    b_id = EsioCi.Router.add_build_to_db(1)
    build = EsioCi.Repo.get(EsioCi.Build, b_id)
    assert build != nil
  end

  test "change build status in DB" do
    q = from p in "projects",
      where: p.name == "test03",
      select: p.id

    p_id = EsioCi.Repo.all(q)

    if Enum.count(p_id) == 0 do
      project = %EsioCi.Project{name: "test03"}
      created_project = EsioCi.Repo.insert!(project)
      project_id = created_project.id
    else
      project_id = List.first(p_id)
    end
    b_id = EsioCi.Router.add_build_to_db(project_id)
    build = EsioCi.Repo.get(EsioCi.Build, b_id)
    assert build != nil
    EsioCi.Common.change_bld_status(b_id, "esioesioesio")
    build = EsioCi.Repo.get(EsioCi.Build, b_id)
    assert build.state == "esioesioesio"
  end
end
