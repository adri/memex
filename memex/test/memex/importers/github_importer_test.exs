defmodule Memex.Importers.GithubImporterTest do
  use ExUnit.Case, async: true

  alias Memex.Importers.GithubImporter

  @items [
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T14:29:13Z",
      "id" => "18352878618",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "pull_request" => %{
          "title" => "[Performance] Automatically compile `.env.*` files to `.env.local.php`",
          "id" => 753_951_469,
          "locked" => false,
          "number" => 22_035,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOAGZWp84s8GLt",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/104180?v=4",
            "events_url" => "https://api.github.com/users/username/events{/privacy}",
            "followers_url" => "https://api.github.com/users/username/followers",
            "following_url" => "https://api.github.com/users/username/following{/other_user}",
            "gists_url" => "https://api.github.com/users/username/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/username",
            "id" => 104_180,
            "login" => "username",
            "node_id" => "MDQ6VXNlcjEwNDE4MA==",
            "organizations_url" => "https://api.github.com/users/username/orgs",
            "received_events_url" => "https://api.github.com/users/username/received_events",
            "repos_url" => "https://api.github.com/users/username/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/username/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/username/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/username"
          },
          "body" => "this is a example messge",
          "url" => "https://api.github.com/repos/Org/Repo/pulls/22035",
          "statuses_url" => "https://api.github.com/repos/Org/Repo/statuses/965c063894a0120944015950e443f434dd30f5ee",
          "closed_at" => nil,
          "updated_at" => "2021-10-08T14:29:12Z",
          "created_at" => "2021-10-08T11:24:57Z",
          "html_url" => "https://github.com/Org/Repo/pull/22035",
          "requested_reviewers" => [],
          "assignees" => [],
          "merged_at" => nil,
          "review_comments_url" => "https://api.github.com/repos/Org/Repo/pulls/22035/comments",
          "assignee" => nil,
          "diff_url" => "https://github.com/Org/Repo/pull/22035.diff",
          "author_association" => "CONTRIBUTOR",
          "patch_url" => "https://github.com/Org/Repo/pull/22035.patch",
          "milestone" => nil,
          "draft" => false,
          "auto_merge" => nil,
          "merge_commit_sha" => "10289fac04dd40eaac94d06016604cffe2f4494b",
          "issue_url" => "https://api.github.com/repos/Org/Repo/issues/22035",
          "base" => %{
            "label" => "Org:main",
            "ref" => "main",
            "repo" => %{
              "labels_url" => "https://api.github.com/repos/Org/Repo/labels{/name}",
              "keys_url" => "https://api.github.com/repos/Org/Repo/keys{/key_id}",
              "fork" => false,
              "owner" => %{
                "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4",
                "events_url" => "https://api.github.com/users/Org/events{/privacy}",
                "followers_url" => "https://api.github.com/users/Org/followers",
                "following_url" => "https://api.github.com/users/Org/following{/other_user}",
                "gists_url" => "https://api.github.com/users/Org/gists{/gist_id}",
                "gravatar_id" => ""
              },
              "hooks_url" => "https://api.github.com/repos/Org/Repo/hooks",
              "id" => 6_706_855,
              "teams_url" => "https://api.github.com/repos/Org/Repo/teams",
              "full_name" => "Org/Repo",
              "git_commits_url" => "https://api.github.com/repos/Org/Repo/git/commits{/sha}",
              "default_branch" => "main"
            },
            "sha" => "4b8cf8f1f467bc3f012ef6290269c19f57704ace",
            "user" => %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4",
              "events_url" => "https://api.github.com/users/Org/events{/privacy}",
              "followers_url" => "https://api.github.com/users/Org/followers",
              "following_url" => "https://api.github.com/users/Org/following{/other_user}",
              "gists_url" => "https://api.github.com/users/Org/gists{/gist_id}",
              "gravatar_id" => "",
              "html_url" => "https://github.com/Org",
              "id" => 5_766_233
            }
          },
          "comments_url" => "https://api.github.com/repos/Org/Repo/issues/22035/comments",
          "commits_url" => "https://api.github.com/repos/Org/Repo/pulls/22035/commits",
          "head" => %{
            "label" => "Org:username/compile-dotenv",
            "ref" => "username/compile-dotenv",
            "repo" => %{
              "labels_url" => "https://api.github.com/repos/Org/Repo/labels{/name}",
              "keys_url" => "https://api.github.com/repos/Org/Repo/keys{/key_id}",
              "fork" => false,
              "owner" => %{
                "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4",
                "events_url" => "https://api.github.com/users/Org/events{/privacy}",
                "followers_url" => "https://api.github.com/users/Org/followers"
              },
              "hooks_url" => "https://api.github.com/repos/Org/Repo/hooks",
              "id" => 6_706_855,
              "teams_url" => "https://api.github.com/repos/Org/Repo/teams"
            },
            "sha" => "965c063894a0120944015950e443f434dd30f5ee",
            "user" => %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4",
              "events_url" => "https://api.github.com/users/Org/events{/privacy}",
              "followers_url" => "https://api.github.com/users/Org/followers",
              "following_url" => "https://api.github.com/users/Org/following{/other_user}",
              "gists_url" => "https://api.github.com/users/Org/gists{/gist_id}"
            }
          },
          "review_comment_url" => "https://api.github.com/repos/Org/Repo/pulls/comments{/number}",
          "_links" => %{
            "comments" => %{
              "href" => "https://api.github.com/repos/Org/Repo/issues/22035/comments"
            },
            "commits" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22035/commits"
            },
            "html" => %{
              "href" => "https://github.com/Org/Repo/pull/22035"
            },
            "issue" => %{
              "href" => "https://api.github.com/repos/Org/Repo/issues/22035"
            },
            "review_comment" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/comments{/number}"
            },
            "review_comments" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22035/comments"
            },
            "self" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22035"
            }
          },
          "labels" => [
            %{
              "color" => "fef2c0",
              "default" => false,
              "description" => nil,
              "id" => 230_263_870,
              "name" => "ready for review",
              "node_id" => "MDU6TGFiZWwyMzAyNjM4NzA="
            }
          ],
          "state" => "open"
        },
        "review" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/Repo/pull/22035#pullrequestreview-775087360"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22035"
            }
          },
          "author_association" => "CONTRIBUTOR",
          "body" => "",
          "commit_id" => "965c063894a0120944015950e443f434dd30f5ee",
          "html_url" => "https://github.com/Org/Repo/pull/22035#pullrequestreview-775087360",
          "id" => 775_087_360,
          "node_id" => "PRR_kwDOAGZWp84uMuUA",
          "pull_request_url" => "https://api.github.com/repos/Org/Repo/pulls/22035",
          "state" => "approved",
          "submitted_at" => "2021-10-08T14:29:12Z",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla",
            "node_id" => "MDQ6VXNlcjEzMzgzMg==",
            "organizations_url" => "https://api.github.com/users/userbla/orgs",
            "received_events_url" => "https://api.github.com/users/userbla/received_events",
            "repos_url" => "https://api.github.com/users/userbla/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/userbla"
          }
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 6_706_855,
        "name" => "Org/Repo",
        "url" => "https://api.github.com/repos/Org/Repo"
      },
      "type" => "PullRequestReviewEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T14:29:03Z",
      "id" => "18352875733",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "comment" => %{
          "author_association" => "CONTRIBUTOR",
          "body" => "It's not that complex so why not. ",
          "created_at" => "2021-10-08T14:29:03Z",
          "html_url" => "https://github.com/Org/Repo/pull/22035#issuecomment-938688550",
          "id" => 938_688_550,
          "issue_url" => "https://api.github.com/repos/Org/Repo/issues/22035",
          "node_id" => "IC_kwDOAGZWp84380Am",
          "performed_via_github_app" => nil,
          "reactions" => %{
            "+1" => 0,
            "-1" => 0,
            "confused" => 0,
            "eyes" => 0,
            "heart" => 0,
            "hooray" => 0,
            "laugh" => 0,
            "rocket" => 0,
            "total_count" => 0,
            "url" => "https://api.github.com/repos/Org/Repo/issues/comments/938688550/reactions"
          },
          "updated_at" => "2021-10-08T14:29:03Z",
          "url" => "https://api.github.com/repos/Org/Repo/issues/comments/938688550",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla",
            "node_id" => "MDQ6VXNlcjEzMzgzMg==",
            "organizations_url" => "https://api.github.com/users/userbla/orgs",
            "received_events_url" => "https://api.github.com/users/userbla/received_events",
            "repos_url" => "https://api.github.com/users/userbla/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/userbla"
          }
        },
        "issue" => %{
          "active_lock_reason" => nil,
          "assignee" => nil,
          "assignees" => [],
          "author_association" => "CONTRIBUTOR",
          "body" => "some message",
          "closed_at" => nil,
          "comments" => 3,
          "comments_url" => "https://api.github.com/repos/Org/Repo/issues/22035/comments",
          "created_at" => "2021-10-08T11:24:57Z",
          "events_url" => "https://api.github.com/repos/Org/Repo/issues/22035/events",
          "html_url" => "https://github.com/Org/Repo/pull/22035",
          "id" => 1_020_989_442,
          "labels" => [
            %{
              "color" => "fef2c0",
              "default" => false,
              "description" => nil,
              "id" => 230_263_870,
              "name" => "ready for review",
              "node_id" => "MDU6TGFiZWwyMzAyNjM4NzA=",
              "url" => "https://api.github.com/repos/Org/Repo/labels/ready%20for%20review"
            }
          ],
          "labels_url" => "https://api.github.com/repos/Org/Repo/issues/22035/labels{/name}",
          "locked" => false,
          "milestone" => nil,
          "node_id" => "PR_kwDOAGZWp84s8GLt",
          "number" => 22_035,
          "performed_via_github_app" => nil,
          "pull_request" => %{
            "diff_url" => "https://github.com/Org/Repo/pull/22035.diff",
            "html_url" => "https://github.com/Org/Repo/pull/22035",
            "patch_url" => "https://github.com/Org/Repo/pull/22035.patch",
            "url" => "https://api.github.com/repos/Org/Repo/pulls/22035"
          },
          "reactions" => %{
            "+1" => 0,
            "-1" => 0,
            "confused" => 0,
            "eyes" => 0,
            "heart" => 0,
            "hooray" => 0,
            "laugh" => 0,
            "rocket" => 0,
            "total_count" => 0,
            "url" => "https://api.github.com/repos/Org/Repo/issues/22035/reactions"
          },
          "repository_url" => "https://api.github.com/repos/Org/Repo",
          "state" => "open",
          "timeline_url" => "https://api.github.com/repos/Org/Repo/issues/22035/timeline",
          "title" => "[Performance] Automatically compile `.env.*` files to `.env.local.php`",
          "updated_at" => "2021-10-08T14:29:03Z",
          "url" => "https://api.github.com/repos/Org/Repo/issues/22035",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/104180?v=4",
            "events_url" => "https://api.github.com/users/username/events{/privacy}",
            "followers_url" => "https://api.github.com/users/username/followers",
            "following_url" => "https://api.github.com/users/username/following{/other_user}",
            "gists_url" => "https://api.github.com/users/username/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/username",
            "id" => 104_180,
            "login" => "username",
            "node_id" => "MDQ6VXNlcjEwNDE4MA==",
            "organizations_url" => "https://api.github.com/users/username/orgs",
            "received_events_url" => "https://api.github.com/users/username/received_events"
          }
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 6_706_855,
        "name" => "Org/Repo",
        "url" => "https://api.github.com/repos/Org/Repo"
      },
      "type" => "IssueCommentEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T13:58:33Z",
      "id" => "18352362383",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "pull_request" => %{
          "title" => "Some fix",
          "id" => 754_047_266,
          "locked" => false,
          "number" => 22_038,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOAGZWp84s8dki",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/104180?v=4",
            "events_url" => "https://api.github.com/users/username/events{/privacy}",
            "followers_url" => "https://api.github.com/users/username/followers",
            "following_url" => "https://api.github.com/users/username/following{/other_user}",
            "gists_url" => "https://api.github.com/users/username/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/username",
            "id" => 104_180,
            "login" => "username",
            "node_id" => "MDQ6VXNlcjEwNDE4MA==",
            "organizations_url" => "https://api.github.com/users/username/orgs",
            "received_events_url" => "https://api.github.com/users/username/received_events",
            "repos_url" => "https://api.github.com/users/username/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/username/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/username/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/username"
          },
          "body" => "some message",
          "url" => "https://api.github.com/repos/Org/Repo/pulls/22038",
          "statuses_url" => "https://api.github.com/repos/Org/Repo/statuses/6690b3492355b3e3734dec1802fa8ce0ef14c40f",
          "closed_at" => nil,
          "updated_at" => "2021-10-08T13:58:32Z",
          "created_at" => "2021-10-08T13:34:48Z",
          "html_url" => "https://github.com/Org/Repo/pull/22038",
          "requested_reviewers" => [],
          "assignees" => [],
          "merged_at" => nil,
          "review_comments_url" => "https://api.github.com/repos/Org/Repo/pulls/22038/comments",
          "assignee" => nil,
          "diff_url" => "https://github.com/Org/Repo/pull/22038.diff",
          "author_association" => "CONTRIBUTOR",
          "patch_url" => "https://github.com/Org/Repo/pull/22038.patch",
          "milestone" => nil,
          "draft" => false,
          "auto_merge" => nil,
          "merge_commit_sha" => "347d9f53d149122cc2588ecd3a90ecaec9d9e45a",
          "issue_url" => "https://api.github.com/repos/Org/Repo/issues/22038",
          "base" => %{
            "label" => "Org:main",
            "ref" => "main",
            "repo" => %{
              "labels_url" => "https://api.github.com/repos/Org/Repo/labels{/name}",
              "keys_url" => "https://api.github.com/repos/Org/Repo/keys{/key_id}",
              "fork" => false,
              "owner" => %{
                "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4",
                "events_url" => "https://api.github.com/users/Org/events{/privacy}",
                "followers_url" => "https://api.github.com/users/Org/followers",
                "following_url" => "https://api.github.com/users/Org/following{/other_user}"
              },
              "hooks_url" => "https://api.github.com/repos/Org/Repo/hooks",
              "id" => 6_706_855,
              "teams_url" => "https://api.github.com/repos/Org/Repo/teams",
              "full_name" => "Org/Repo"
            },
            "sha" => "4b8cf8f1f467bc3f012ef6290269c19f57704ace",
            "user" => %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4",
              "events_url" => "https://api.github.com/users/Org/events{/privacy}",
              "followers_url" => "https://api.github.com/users/Org/followers",
              "following_url" => "https://api.github.com/users/Org/following{/other_user}",
              "gists_url" => "https://api.github.com/users/Org/gists{/gist_id}",
              "gravatar_id" => ""
            }
          },
          "comments_url" => "https://api.github.com/repos/Org/Repo/issues/22038/comments",
          "commits_url" => "https://api.github.com/repos/Org/Repo/pulls/22038/commits",
          "head" => %{
            "label" => "Org:username/graphql-perf-test",
            "ref" => "username/graphql-perf-test",
            "repo" => %{
              "labels_url" => "https://api.github.com/repos/Org/Repo/labels{/name}",
              "keys_url" => "https://api.github.com/repos/Org/Repo/keys{/key_id}",
              "fork" => false,
              "owner" => %{
                "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4"
              },
              "hooks_url" => "https://api.github.com/repos/Org/Repo/hooks"
            },
            "sha" => "6690b3492355b3e3734dec1802fa8ce0ef14c40f",
            "user" => %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4",
              "events_url" => "https://api.github.com/users/Org/events{/privacy}",
              "followers_url" => "https://api.github.com/users/Org/followers"
            }
          },
          "review_comment_url" => "https://api.github.com/repos/Org/Repo/pulls/comments{/number}",
          "_links" => %{
            "comments" => %{
              "href" => "https://api.github.com/repos/Org/Repo/issues/22038/comments"
            },
            "commits" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22038/commits"
            },
            "html" => %{
              "href" => "https://github.com/Org/Repo/pull/22038"
            },
            "issue" => %{
              "href" => "https://api.github.com/repos/Org/Repo/issues/22038"
            },
            "review_comment" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/comments{/number}"
            },
            "review_comments" => %{}
          },
          "labels" => [
            %{
              "color" => "fef2c0",
              "default" => false,
              "description" => nil,
              "id" => 230_263_870
            }
          ],
          "state" => "open"
        },
        "review" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/Repo/pull/22038#pullrequestreview-775047151"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22038"
            }
          },
          "author_association" => "CONTRIBUTOR",
          "body" => "This looks a lot nicer!",
          "commit_id" => "6690b3492355b3e3734dec1802fa8ce0ef14c40f",
          "html_url" => "https://github.com/Org/Repo/pull/22038#pullrequestreview-775047151",
          "id" => 775_047_151,
          "node_id" => "PRR_kwDOAGZWp84uMkfv",
          "pull_request_url" => "https://api.github.com/repos/Org/Repo/pulls/22038",
          "state" => "approved",
          "submitted_at" => "2021-10-08T13:58:32Z",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla",
            "node_id" => "MDQ6VXNlcjEzMzgzMg==",
            "organizations_url" => "https://api.github.com/users/userbla/orgs",
            "received_events_url" => "https://api.github.com/users/userbla/received_events",
            "repos_url" => "https://api.github.com/users/userbla/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/userbla"
          }
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 6_706_855,
        "name" => "Org/Repo",
        "url" => "https://api.github.com/repos/Org/Repo"
      },
      "type" => "PullRequestReviewEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T13:33:34Z",
      "id" => "18351951602",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "pull_request" => %{
          "title" => "Add more things",
          "id" => 754_028_139,
          "locked" => false,
          "number" => 11,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOCNe_5M4s8Y5r",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/106844?v=4",
            "events_url" => "https://api.github.com/users/some_user/events{/privacy}",
            "followers_url" => "https://api.github.com/users/some_user/followers",
            "following_url" => "https://api.github.com/users/some_user/following{/other_user}",
            "gists_url" => "https://api.github.com/users/some_user/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/some_user",
            "id" => 106_123,
            "login" => "some_user",
            "node_id" => "MDQ6VXNlcjEwNjg0NA==",
            "organizations_url" => "https://api.github.com/users/some_user/orgs",
            "received_events_url" => "https://api.github.com/users/some_user/received_events",
            "repos_url" => "https://api.github.com/users/some_user/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/some_user/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/some_user/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/some_user"
          },
          "body" => "some message",
          "url" => "https://api.github.com/repos/Org/repo5/pulls/11",
          "statuses_url" => "https://api.github.com/repos/Org/repo5/statuses/f69beb6305be9da59f8d203dcbb4c3041d2206b1",
          "closed_at" => nil,
          "updated_at" => "2021-10-08T13:33:33Z",
          "created_at" => "2021-10-08T13:11:29Z",
          "html_url" => "https://github.com/Org/repo5/pull/11",
          "requested_reviewers" => [],
          "assignees" => [],
          "merged_at" => nil,
          "review_comments_url" => "https://api.github.com/repos/Org/repo5/pulls/11/comments",
          "assignee" => nil,
          "diff_url" => "https://github.com/Org/repo5/pull/11.diff",
          "author_association" => "NONE",
          "patch_url" => "https://github.com/Org/repo5/pull/11.patch",
          "milestone" => nil,
          "draft" => false,
          "auto_merge" => nil,
          "merge_commit_sha" => "e8b5cfd2df31ac2c96d00e3eb0986bf5014df005",
          "issue_url" => "https://api.github.com/repos/Org/repo5/issues/11",
          "base" => %{
            "label" => "Org:main",
            "ref" => "main",
            "repo" => %{
              "labels_url" => "https://api.github.com/repos/Org/repo5/labels{/name}",
              "keys_url" => "https://api.github.com/repos/Org/repo5/keys{/key_id}",
              "fork" => false,
              "owner" => %{
                "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4",
                "events_url" => "https://api.github.com/users/Org/events{/privacy}",
                "followers_url" => "https://api.github.com/users/Org/followers"
              },
              "hooks_url" => "https://api.github.com/repos/Org/repo5/hooks",
              "id" => 148_357_092,
              "teams_url" => "https://api.github.com/repos/Org/repo5/teams"
            },
            "sha" => "6ee81d41b1ebc221ceb4a22dfb3bf67e3bd71407",
            "user" => %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4",
              "events_url" => "https://api.github.com/users/Org/events{/privacy}",
              "followers_url" => "https://api.github.com/users/Org/followers",
              "following_url" => "https://api.github.com/users/Org/following{/other_user}",
              "gists_url" => "https://api.github.com/users/Org/gists{/gist_id}"
            }
          },
          "comments_url" => "https://api.github.com/repos/Org/repo5/issues/11/comments",
          "commits_url" => "https://api.github.com/repos/Org/repo5/pulls/11/commits",
          "head" => %{
            "label" => "Org:some_user/add_tickets_for_predictions",
            "ref" => "some_user/add_tickets_for_predictions",
            "repo" => %{
              "labels_url" => "https://api.github.com/repos/Org/repo5/labels{/name}",
              "keys_url" => "https://api.github.com/repos/Org/repo5/keys{/key_id}",
              "fork" => false,
              "owner" => %{}
            },
            "sha" => "f69beb6305be9da59f8d203dcbb4c3041d2206b1",
            "user" => %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/123456?v=4",
              "events_url" => "https://api.github.com/users/Org/events{/privacy}"
            }
          },
          "review_comment_url" => "https://api.github.com/repos/Org/repo5/pulls/comments{/number}",
          "_links" => %{
            "comments" => %{
              "href" => "https://api.github.com/repos/Org/repo5/issues/11/comments"
            },
            "commits" => %{
              "href" => "https://api.github.com/repos/Org/repo5/pulls/11/commits"
            },
            "html" => %{
              "href" => "https://github.com/Org/repo5/pull/11"
            },
            "issue" => %{
              "href" => "https://api.github.com/repos/Org/repo5/issues/11"
            },
            "review_comment" => %{}
          },
          "labels" => [
            %{"color" => "fef2c0", "default" => false, "description" => nil}
          ],
          "state" => "open"
        },
        "review" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/repo5/pull/11#pullrequestreview-775018384"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/repo5/pulls/11"
            }
          },
          "author_association" => "CONTRIBUTOR",
          "body" => "",
          "commit_id" => "f69beb6305be9da59f8d203dcbb4c3041d2206b1",
          "html_url" => "https://github.com/Org/repo5/pull/11#pullrequestreview-775018384",
          "id" => 775_018_384,
          "node_id" => "PRR_kwDOCNe_5M4uMdeQ",
          "pull_request_url" => "https://api.github.com/repos/Org/repo5/pulls/11",
          "state" => "approved",
          "submitted_at" => "2021-10-08T13:33:33Z",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla",
            "node_id" => "MDQ6VXNlcjEzMzgzMg==",
            "organizations_url" => "https://api.github.com/users/userbla/orgs",
            "received_events_url" => "https://api.github.com/users/userbla/received_events",
            "repos_url" => "https://api.github.com/users/userbla/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/userbla"
          }
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 148_357_092,
        "name" => "Org/repo5",
        "url" => "https://api.github.com/repos/Org/repo5"
      },
      "type" => "PullRequestReviewEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T13:31:57Z",
      "id" => "18351925935",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "before" => "f14d3018d7f57efec6ae73d67addbb2dc5084b1a",
        "commits" => [
          %{
            "author" => %{
              "email" => "someone@Org.com",
              "name" => "Some Name"
            },
            "distinct" => true,
            "message" => "some message",
            "sha" => "26cb9aaacb36ea850ce98feacf3f902274e523ed",
            "url" => "https://api.github.com/repos/Org/repo2/commits/26cb9aaacb36ea850ce98feacf3f902274e523ed"
          }
        ],
        "distinct_size" => 1,
        "head" => "26cb9aaacb36ea850ce98feacf3f902274e523ed",
        "push_id" => 8_112_468_583,
        "ref" => "refs/heads/main",
        "size" => 1
      },
      "public" => false,
      "repo" => %{
        "id" => 414_918_716,
        "name" => "Org/repo2",
        "url" => "https://api.github.com/repos/Org/repo2"
      },
      "type" => "PushEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T13:03:45Z",
      "id" => "18351474510",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "before" => "22ee40ccbc4f94fc5cc51fc6c9fe95cbbe2f7b14",
        "commits" => [
          %{
            "author" => %{
              "email" => "someone@Org.com",
              "name" => "Some Name"
            },
            "distinct" => true,
            "message" => "Support bla",
            "sha" => "022b9634ec1483bf77d6e883b8c668c9314cb14b",
            "url" => "https://api.github.com/repos/Org/repo2/commits/022b9634ec1483bf77d6e883b8c668c9314cb14b"
          },
          %{
            "author" => %{
              "email" => "someone@Org.com",
              "name" => "Some Name"
            },
            "distinct" => true,
            "message" => "Make bla",
            "sha" => "799477b2fc61e04b854647f66c7d7152affe1e23",
            "url" => "https://api.github.com/repos/Org/repo2/commits/799477b2fc61e04b854647f66c7d7152affe1e23"
          }
        ],
        "distinct_size" => 2,
        "head" => "799477b2fc61e04b854647f66c7d7152affe1e23",
        "push_id" => 8_112_246_731,
        "ref" => "refs/heads/main",
        "size" => 2
      },
      "public" => false,
      "repo" => %{
        "id" => 414_918_716,
        "name" => "Org/repo2",
        "url" => "https://api.github.com/repos/Org/repo2"
      },
      "type" => "PushEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:59:05Z",
      "id" => "18351398341",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "before" => "d2daa6742f081bb4daeb353276a1b580809b1442",
        "commits" => [
          %{
            "author" => %{
              "email" => "someone@Org.com",
              "name" => "Some Name"
            },
            "distinct" => true,
            "message" => "Fix name",
            "sha" => "22ee40ccbc4f94fc5cc51fc6c9fe95cbbe2f7b14",
            "url" => "https://api.github.com/repos/Org/repo2/commits/22ee40ccbc4f94fc5cc51fc6c9fe95cbbe2f7b14"
          }
        ],
        "distinct_size" => 1,
        "head" => "22ee40ccbc4f94fc5cc51fc6c9fe95cbbe2f7b14",
        "push_id" => 8_112_208_024,
        "ref" => "refs/heads/main",
        "size" => 1
      },
      "public" => false,
      "repo" => %{
        "id" => 414_918_716,
        "name" => "Org/repo2",
        "url" => "https://api.github.com/repos/Org/repo2"
      },
      "type" => "PushEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:54:52Z",
      "id" => "18351333457",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "before" => "59364248fecac3c8f0aca1b737d41dccb7113639",
        "commits" => [
          %{
            "author" => %{
              "email" => "someone@Org.com",
              "name" => "Some Name"
            },
            "distinct" => true,
            "message" => "Enable deployments",
            "sha" => "d2daa6742f081bb4daeb353276a1b580809b1442",
            "url" => "https://api.github.com/repos/Org/repo2/commits/d2daa6742f081bb4daeb353276a1b580809b1442"
          }
        ],
        "distinct_size" => 1,
        "head" => "d2daa6742f081bb4daeb353276a1b580809b1442",
        "push_id" => 8_112_175_114,
        "ref" => "refs/heads/main",
        "size" => 1
      },
      "public" => false,
      "repo" => %{
        "id" => 414_918_716,
        "name" => "Org/repo2",
        "url" => "https://api.github.com/repos/Org/repo2"
      },
      "type" => "PushEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:51:14Z",
      "id" => "18351277822",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "before" => "ed69061e7c7f61aff1c9594d4944f3f0833ad64b",
        "commits" => [
          %{
            "author" => %{
              "email" => "someone@Org.com",
              "name" => "Some Name"
            },
            "distinct" => true,
            "message" => "Fix mock",
            "sha" => "59364248fecac3c8f0aca1b737d41dccb7113639",
            "url" => "https://api.github.com/repos/Org/repo2/commits/59364248fecac3c8f0aca1b737d41dccb7113639"
          }
        ],
        "distinct_size" => 1,
        "head" => "59364248fecac3c8f0aca1b737d41dccb7113639",
        "push_id" => 8_112_146_754,
        "ref" => "refs/heads/main",
        "size" => 1
      },
      "public" => false,
      "repo" => %{
        "id" => 414_918_716,
        "name" => "Org/repo2",
        "url" => "https://api.github.com/repos/Org/repo2"
      },
      "type" => "PushEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:44:12Z",
      "id" => "18351170452",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "before" => "c36bdfdb6bf9cdc028eb7e47e3a22442de3140fb",
        "commits" => [
          %{
            "author" => %{
              "email" => "someone@Org.com",
              "name" => "Some Name"
            },
            "distinct" => true,
            "message" => "So we can deploy repo2.",
            "sha" => "cdca2dc43116b15e5fba0709b79191f34546fb40",
            "url" => "https://api.github.com/repos/Org/repo4/commits/cdca2dc43116b15e5fba0709b79191f34546fb40"
          }
        ],
        "distinct_size" => 1,
        "head" => "cdca2dc43116b15e5fba0709b79191f34546fb40",
        "push_id" => 8_112_093_993,
        "ref" => "refs/heads/master",
        "size" => 1
      },
      "public" => false,
      "repo" => %{
        "id" => 159_508_792,
        "name" => "Org/repo4",
        "url" => "https://api.github.com/repos/Org/repo4"
      },
      "type" => "PushEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:44:11Z",
      "id" => "18351170272",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "closed",
        "number" => 167,
        "pull_request" => %{
          "additions" => 81,
          "title" => "Add things",
          "comments" => 0,
          "id" => 754_005_054,
          "merged_by" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla",
            "node_id" => "MDQ6VXNlcjEzMzgzMg==",
            "organizations_url" => "https://api.github.com/users/userbla/orgs",
            "received_events_url" => "https://api.github.com/users/userbla/received_events",
            "repos_url" => "https://api.github.com/users/userbla/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/userbla"
          },
          "locked" => false,
          "number" => 167,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOCYHpOM4s8TQ-",
          "requested_teams" => [],
          "mergeable" => nil,
          "maintainer_can_modify" => false,
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla",
            "node_id" => "MDQ6VXNlcjEzMzgzMg==",
            "organizations_url" => "https://api.github.com/users/userbla/orgs",
            "received_events_url" => "https://api.github.com/users/userbla/received_events",
            "repos_url" => "https://api.github.com/users/userbla/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/userbla"
          },
          "body" => "So we can deploy repo2.",
          "url" => "https://api.github.com/repos/Org/repo4/pulls/167",
          "statuses_url" => "https://api.github.com/repos/Org/repo4/statuses/3feaf61c5fedb648af0555f8e5f0e8835c403be0",
          "closed_at" => "2021-10-08T12:44:11Z",
          "updated_at" => "2021-10-08T12:44:11Z",
          "created_at" => "2021-10-08T12:40:38Z",
          "html_url" => "https://github.com/Org/repo4/pull/167",
          "rebaseable" => nil,
          "requested_reviewers" => [],
          "assignees" => [],
          "merged_at" => "2021-10-08T12:44:11Z",
          "review_comments" => 0,
          "review_comments_url" => "https://api.github.com/repos/Org/repo4/pulls/167/comments",
          "assignee" => nil,
          "diff_url" => "https://github.com/Org/repo4/pull/167.diff",
          "author_association" => "CONTRIBUTOR",
          "patch_url" => "https://github.com/Org/repo4/pull/167.patch",
          "milestone" => nil
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 159_508_792,
        "name" => "Org/repo4",
        "url" => "https://api.github.com/repos/Org/repo4"
      },
      "type" => "PullRequestEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:44:12Z",
      "id" => "18351170344",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "pusher_type" => "user",
        "ref" => "userbla/ds-namespace-pizza",
        "ref_type" => "branch"
      },
      "public" => false,
      "repo" => %{
        "id" => 159_508_792,
        "name" => "Org/repo4",
        "url" => "https://api.github.com/repos/Org/repo4"
      },
      "type" => "DeleteEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:40:38Z",
      "id" => "18351118396",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "opened",
        "number" => 167,
        "pull_request" => %{
          "additions" => 81,
          "title" => "Add things",
          "comments" => 0,
          "id" => 754_005_054,
          "merged_by" => nil,
          "locked" => false,
          "number" => 167,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOCYHpOM4s8TQ-",
          "requested_teams" => [],
          "mergeable" => nil,
          "maintainer_can_modify" => false,
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla",
            "node_id" => "MDQ6VXNlcjEzMzgzMg==",
            "organizations_url" => "https://api.github.com/users/userbla/orgs",
            "received_events_url" => "https://api.github.com/users/userbla/received_events",
            "repos_url" => "https://api.github.com/users/userbla/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions"
          },
          "body" => "So we can deploy repo2.",
          "url" => "https://api.github.com/repos/Org/repo4/pulls/167",
          "statuses_url" => "https://api.github.com/repos/Org/repo4/statuses/3feaf61c5fedb648af0555f8e5f0e8835c403be0",
          "closed_at" => nil,
          "updated_at" => "2021-10-08T12:40:38Z",
          "created_at" => "2021-10-08T12:40:38Z",
          "html_url" => "https://github.com/Org/repo4/pull/167",
          "rebaseable" => nil,
          "requested_reviewers" => [
            %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/28565699?v=4",
              "events_url" => "https://api.github.com/users/janavenkat/events{/privacy}",
              "followers_url" => "https://api.github.com/users/janavenkat/followers",
              "following_url" => "https://api.github.com/users/janavenkat/following{/other_user}",
              "gists_url" => "https://api.github.com/users/janavenkat/gists{/gist_id}",
              "gravatar_id" => ""
            }
          ],
          "assignees" => [],
          "merged_at" => nil,
          "review_comments" => 0,
          "review_comments_url" => "https://api.github.com/repos/Org/repo4/pulls/167/comments",
          "assignee" => nil,
          "diff_url" => "https://github.com/Org/repo4/pull/167.diff",
          "author_association" => "CONTRIBUTOR"
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 159_508_792,
        "name" => "Org/repo4",
        "url" => "https://api.github.com/repos/Org/repo4"
      },
      "type" => "PullRequestEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:40:25Z",
      "id" => "18351115146",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "description" => "Org repo4 Kubernetes Cluster",
        "master_branch" => "master",
        "pusher_type" => "user",
        "ref" => "userbla/ds-namespace-pizza",
        "ref_type" => "branch"
      },
      "public" => false,
      "repo" => %{
        "id" => 159_508_792,
        "name" => "Org/repo4",
        "url" => "https://api.github.com/repos/Org/repo4"
      },
      "type" => "CreateEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:28:42Z",
      "id" => "18350947079",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "pull_request" => %{
          "title" => "Build stuff",
          "id" => 753_989_282,
          "locked" => false,
          "number" => 587,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOCygD2c4s8Pai",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/22071649?v=4",
            "events_url" => "https://api.github.com/users/someuser/events{/privacy}",
            "followers_url" => "https://api.github.com/users/someuser/followers",
            "following_url" => "https://api.github.com/users/someuser/following{/other_user}",
            "gists_url" => "https://api.github.com/users/someuser/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/someuser",
            "id" => 22_071_649,
            "login" => "someuser",
            "node_id" => "MDQ6VXNlcjIyMDcxNjQ5",
            "organizations_url" => "https://api.github.com/users/someuser/orgs",
            "received_events_url" => "https://api.github.com/users/someuser/received_events",
            "repos_url" => "https://api.github.com/users/someuser/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/someuser/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/someuser/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/someuser"
          },
          "body" => "Fixes something",
          "url" => "https://api.github.com/repos/Org/repo3/pulls/587",
          "statuses_url" => "https://api.github.com/repos/Org/repo3/statuses/a8c27b9d470fb227e81a413ad420dd61a98f6abe",
          "closed_at" => nil,
          "updated_at" => "2021-10-08T12:28:42Z",
          "created_at" => "2021-10-08T12:20:42Z",
          "html_url" => "https://github.com/Org/repo3/pull/587",
          "requested_reviewers" => [],
          "assignees" => [],
          "merged_at" => nil,
          "review_comments_url" => "https://api.github.com/repos/Org/repo3/pulls/587/comments",
          "assignee" => nil,
          "diff_url" => "https://github.com/Org/repo3/pull/587.diff",
          "author_association" => "MEMBER",
          "patch_url" => "https://github.com/Org/repo3/pull/587.patch",
          "milestone" => nil,
          "draft" => false,
          "auto_merge" => nil,
          "merge_commit_sha" => "70f95937fa4ca123e71d25b121d7afe1c673f2be",
          "issue_url" => "https://api.github.com/repos/Org/repo3/issues/587"
        },
        "review" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/repo3/pull/587#pullrequestreview-774949306"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/repo3/pulls/587"
            }
          },
          "author_association" => "MEMBER",
          "body" => nil,
          "commit_id" => "a8c27b9d470fb227e81a413ad420dd61a98f6abe",
          "html_url" => "https://github.com/Org/repo3/pull/587#pullrequestreview-774949306",
          "id" => 774_949_306,
          "node_id" => "PRR_kwDOCygD2c4uMMm6",
          "pull_request_url" => "https://api.github.com/repos/Org/repo3/pulls/587",
          "state" => "commented",
          "submitted_at" => "2021-10-08T12:28:42Z",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla",
            "node_id" => "MDQ6VXNlcjEzMzgzMg==",
            "organizations_url" => "https://api.github.com/users/userbla/orgs",
            "received_events_url" => "https://api.github.com/users/userbla/received_events",
            "repos_url" => "https://api.github.com/users/userbla/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions"
          }
        }
      },
      "public" => true,
      "repo" => %{
        "id" => 187_171_801,
        "name" => "Org/repo3",
        "url" => "https://api.github.com/repos/Org/repo3"
      },
      "type" => "PullRequestReviewEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:28:42Z",
      "id" => "18350947104",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "comment" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/repo3/pull/587#discussion_r724966818"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/repo3/pulls/587"
            },
            "self" => %{
              "href" => "https://api.github.com/repos/Org/repo3/pulls/comments/724966818"
            }
          },
          "author_association" => "MEMBER",
          "body" => "Some review",
          "commit_id" => "a8c27b9d470fb227e81a413ad420dd61a98f6abe",
          "created_at" => "2021-10-08T12:28:42Z",
          "diff_hunk" => "",
          "html_url" => "https://github.com/Org/repo3/pull/587#discussion_r724966818",
          "id" => 724_966_818,
          "line" => 14,
          "node_id" => "PRRC_kwDOCygD2c4rNh2i",
          "original_commit_id" => "a8c27b9d470fb227e81a413ad420dd61a98f6abe",
          "original_line" => 14,
          "original_position" => 14,
          "original_start_line" => nil,
          "path" => "somepath",
          "position" => 14,
          "pull_request_review_id" => 774_949_306,
          "pull_request_url" => "https://api.github.com/repos/Org/repo3/pulls/587",
          "reactions" => %{
            "+1" => 0,
            "-1" => 0,
            "confused" => 0,
            "eyes" => 0,
            "heart" => 0,
            "hooray" => 0,
            "laugh" => 0,
            "rocket" => 0
          },
          "side" => "RIGHT",
          "start_line" => nil,
          "start_side" => nil,
          "updated_at" => "2021-10-08T12:28:42Z",
          "url" => "https://api.github.com/repos/Org/repo3/pulls/comments/724966818",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}"
          }
        },
        "pull_request" => %{
          "title" => "Build stuff",
          "id" => 753_989_282,
          "locked" => false,
          "number" => 587,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOCygD2c4s8Pai",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/22071649?v=4",
            "events_url" => "https://api.github.com/users/someuser/events{/privacy}",
            "followers_url" => "https://api.github.com/users/someuser/followers",
            "following_url" => "https://api.github.com/users/someuser/following{/other_user}",
            "gists_url" => "https://api.github.com/users/someuser/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/someuser",
            "id" => 22_071_649,
            "login" => "someuser",
            "node_id" => "MDQ6VXNlcjIyMDcxNjQ5",
            "organizations_url" => "https://api.github.com/users/someuser/orgs",
            "received_events_url" => "https://api.github.com/users/someuser/received_events",
            "repos_url" => "https://api.github.com/users/someuser/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/someuser/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/someuser/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/someuser"
          },
          "body" => "some text",
          "url" => "https://api.github.com/repos/Org/repo3/pulls/587",
          "statuses_url" => "https://api.github.com/repos/Org/repo3/statuses/a8c27b9d470fb227e81a413ad420dd61a98f6abe",
          "closed_at" => nil,
          "updated_at" => "2021-10-08T12:28:42Z",
          "created_at" => "2021-10-08T12:20:42Z",
          "html_url" => "https://github.com/Org/repo3/pull/587",
          "requested_reviewers" => [],
          "assignees" => [],
          "merged_at" => nil,
          "review_comments_url" => "https://api.github.com/repos/Org/repo3/pulls/587/comments",
          "assignee" => nil,
          "diff_url" => "https://github.com/Org/repo3/pull/587.diff",
          "author_association" => "MEMBER",
          "patch_url" => "https://github.com/Org/repo3/pull/587.patch",
          "milestone" => nil,
          "draft" => false,
          "auto_merge" => nil
        }
      },
      "public" => true,
      "repo" => %{
        "id" => 187_171_801,
        "name" => "Org/repo3",
        "url" => "https://api.github.com/repos/Org/repo3"
      },
      "type" => "PullRequestReviewCommentEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:24:30Z",
      "id" => "18350885362",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "before" => "26f431f67778339d11eef9cd492c7d05d5e626ab",
        "commits" => [
          %{
            "author" => %{
              "email" => "someone@Org.com",
              "name" => "Some Name"
            },
            "distinct" => true,
            "message" => "Don't depend on not existing jobs",
            "sha" => "ed69061e7c7f61aff1c9594d4944f3f0833ad64b",
            "url" => "https://api.github.com/repos/Org/repo2/commits/ed69061e7c7f61aff1c9594d4944f3f0833ad64b"
          }
        ],
        "distinct_size" => 1,
        "head" => "ed69061e7c7f61aff1c9594d4944f3f0833ad64b",
        "push_id" => 8_111_949_255,
        "ref" => "refs/heads/main",
        "size" => 1
      },
      "public" => false,
      "repo" => %{
        "id" => 414_918_716,
        "name" => "Org/repo2",
        "url" => "https://api.github.com/repos/Org/repo2"
      },
      "type" => "PushEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:23:25Z",
      "id" => "18350869920",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "comment" => %{
          "author_association" => "CONTRIBUTOR",
          "body" => "Some question?",
          "created_at" => "2021-10-08T12:23:24Z",
          "html_url" => "https://github.com/Org/Repo/pull/22035#issuecomment-938600049",
          "id" => 938_600_049,
          "issue_url" => "https://api.github.com/repos/Org/Repo/issues/22035",
          "node_id" => "IC_kwDOAGZWp8438eZx",
          "performed_via_github_app" => nil,
          "reactions" => %{
            "+1" => 0,
            "-1" => 0,
            "confused" => 0,
            "eyes" => 0,
            "heart" => 0,
            "hooray" => 0,
            "laugh" => 0,
            "rocket" => 0,
            "total_count" => 0,
            "url" => "https://api.github.com/repos/Org/Repo/issues/comments/938600049/reactions"
          },
          "updated_at" => "2021-10-08T12:23:24Z",
          "url" => "https://api.github.com/repos/Org/Repo/issues/comments/938600049",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla",
            "node_id" => "MDQ6VXNlcjEzMzgzMg==",
            "organizations_url" => "https://api.github.com/users/userbla/orgs",
            "received_events_url" => "https://api.github.com/users/userbla/received_events",
            "repos_url" => "https://api.github.com/users/userbla/repos"
          }
        },
        "issue" => %{
          "active_lock_reason" => nil,
          "assignee" => nil,
          "assignees" => [],
          "author_association" => "CONTRIBUTOR",
          "body" => "this does stuff",
          "closed_at" => nil,
          "comments" => 1,
          "comments_url" => "https://api.github.com/repos/Org/Repo/issues/22035/comments",
          "created_at" => "2021-10-08T11:24:57Z",
          "events_url" => "https://api.github.com/repos/Org/Repo/issues/22035/events",
          "html_url" => "https://github.com/Org/Repo/pull/22035",
          "id" => 1_020_989_442,
          "labels" => [
            %{
              "color" => "fef2c0",
              "default" => false,
              "description" => nil,
              "id" => 230_263_870,
              "name" => "ready for review",
              "node_id" => "MDU6TGFiZWwyMzAyNjM4NzA=",
              "url" => "https://api.github.com/repos/Org/Repo/labels/ready%20for%20review"
            }
          ],
          "labels_url" => "https://api.github.com/repos/Org/Repo/issues/22035/labels{/name}",
          "locked" => false,
          "milestone" => nil,
          "node_id" => "PR_kwDOAGZWp84s8GLt",
          "number" => 22_035,
          "performed_via_github_app" => nil,
          "pull_request" => %{
            "diff_url" => "https://github.com/Org/Repo/pull/22035.diff",
            "html_url" => "https://github.com/Org/Repo/pull/22035",
            "patch_url" => "https://github.com/Org/Repo/pull/22035.patch",
            "url" => "https://api.github.com/repos/Org/Repo/pulls/22035"
          },
          "reactions" => %{"+1" => 0, "-1" => 0, "confused" => 0},
          "repository_url" => "https://api.github.com/repos/Org/Repo",
          "state" => "open",
          "timeline_url" => "https://api.github.com/repos/Org/Repo/issues/22035/timeline"
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 6_706_855,
        "name" => "Org/Repo",
        "url" => "https://api.github.com/repos/Org/Repo"
      },
      "type" => "IssueCommentEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T12:15:31Z",
      "id" => "18350756910",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "before" => "e3ee501bf502d904120baafa76a7ca794c4c45e0",
        "commits" => [
          %{
            "author" => %{
              "email" => "someone@Org.com",
              "name" => "Some Name"
            },
            "distinct" => true,
            "message" => "Deploy",
            "sha" => "26f431f67778339d11eef9cd492c7d05d5e626ab",
            "url" => "https://api.github.com/repos/Org/repo2/commits/26f431f67778339d11eef9cd492c7d05d5e626ab"
          }
        ],
        "distinct_size" => 1,
        "head" => "26f431f67778339d11eef9cd492c7d05d5e626ab",
        "push_id" => 8_111_884_691,
        "ref" => "refs/heads/main",
        "size" => 1
      },
      "public" => false,
      "repo" => %{
        "id" => 414_918_716,
        "name" => "Org/repo2",
        "url" => "https://api.github.com/repos/Org/repo2"
      },
      "type" => "PushEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T10:25:21Z",
      "id" => "18349292265",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "comment" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/Repo/pull/22033#discussion_r724892610"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22033"
            },
            "self" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/comments/724892610"
            }
          },
          "author_association" => "CONTRIBUTOR",
          "body" => "Makes sense :) ",
          "commit_id" => "79bbabc1512033f1bff8790c712d69996f2377a7",
          "created_at" => "2021-10-08T10:25:21Z",
          "diff_hunk" => "",
          "html_url" => "https://github.com/Org/Repo/pull/22033#discussion_r724892610",
          "id" => 724_892_610,
          "in_reply_to_id" => 724_878_433,
          "line" => 32,
          "node_id" => "PRRC_kwDOAGZWp84rNPvC",
          "original_commit_id" => "79bbabc1512033f1bff8790c712d69996f2377a7",
          "original_line" => 32,
          "original_position" => 32,
          "original_start_line" => nil,
          "path" => "somepath",
          "position" => 32,
          "pull_request_review_id" => 774_848_552,
          "pull_request_url" => "https://api.github.com/repos/Org/Repo/pulls/22033",
          "reactions" => %{"+1" => 0, "-1" => 0, "confused" => 0},
          "side" => "RIGHT",
          "start_line" => nil,
          "start_side" => nil
        },
        "pull_request" => %{
          "title" => "Some title",
          "id" => 753_883_893,
          "locked" => false,
          "number" => 22_033,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOAGZWp84s71r1",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/104180?v=4",
            "events_url" => "https://api.github.com/users/username/events{/privacy}",
            "followers_url" => "https://api.github.com/users/username/followers",
            "following_url" => "https://api.github.com/users/username/following{/other_user}",
            "gists_url" => "https://api.github.com/users/username/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/username",
            "id" => 104_180,
            "login" => "username",
            "node_id" => "MDQ6VXNlcjEwNDE4MA==",
            "organizations_url" => "https://api.github.com/users/username/orgs",
            "received_events_url" => "https://api.github.com/users/username/received_events",
            "repos_url" => "https://api.github.com/users/username/repos",
            "site_admin" => false
          },
          "body" => "Fixed config",
          "url" => "https://api.github.com/repos/Org/Repo/pulls/22033",
          "statuses_url" => "https://api.github.com/repos/Org/Repo/statuses/79bbabc1512033f1bff8790c712d69996f2377a7",
          "closed_at" => "2021-10-08T10:24:22Z",
          "updated_at" => "2021-10-08T10:25:22Z",
          "created_at" => "2021-10-08T09:49:36Z",
          "html_url" => "https://github.com/Org/Repo/pull/22033",
          "requested_reviewers" => [
            %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/1238070?v=4",
              "events_url" => "https://api.github.com/users/SavageTiger/events{/privacy}",
              "followers_url" => "https://api.github.com/users/SavageTiger/followers",
              "following_url" => "https://api.github.com/users/SavageTiger/following{/other_user}",
              "gists_url" => "https://api.github.com/users/SavageTiger/gists{/gist_id}"
            }
          ],
          "assignees" => [],
          "merged_at" => "2021-10-08T10:24:22Z",
          "review_comments_url" => "https://api.github.com/repos/Org/Repo/pulls/22033/comments",
          "assignee" => nil,
          "diff_url" => "https://github.com/Org/Repo/pull/22033.diff",
          "author_association" => "CONTRIBUTOR"
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 6_706_855,
        "name" => "Org/Repo",
        "url" => "https://api.github.com/repos/Org/Repo"
      },
      "type" => "PullRequestReviewCommentEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T10:25:22Z",
      "id" => "18349292234",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "pull_request" => %{
          "title" => "Some title",
          "id" => 753_883_893,
          "locked" => false,
          "number" => 22_033,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOAGZWp84s71r1",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/104180?v=4",
            "events_url" => "https://api.github.com/users/username/events{/privacy}",
            "followers_url" => "https://api.github.com/users/username/followers",
            "following_url" => "https://api.github.com/users/username/following{/other_user}",
            "gists_url" => "https://api.github.com/users/username/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/username",
            "id" => 104_180,
            "login" => "username",
            "node_id" => "MDQ6VXNlcjEwNDE4MA==",
            "organizations_url" => "https://api.github.com/users/username/orgs",
            "received_events_url" => "https://api.github.com/users/username/received_events",
            "repos_url" => "https://api.github.com/users/username/repos",
            "site_admin" => false
          },
          "body" => "Fixed config",
          "url" => "https://api.github.com/repos/Org/Repo/pulls/22033",
          "statuses_url" => "https://api.github.com/repos/Org/Repo/statuses/79bbabc1512033f1bff8790c712d69996f2377a7",
          "closed_at" => "2021-10-08T10:24:22Z",
          "updated_at" => "2021-10-08T10:25:22Z",
          "created_at" => "2021-10-08T09:49:36Z",
          "html_url" => "https://github.com/Org/Repo/pull/22033",
          "requested_reviewers" => [
            %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/1238070?v=4",
              "events_url" => "https://api.github.com/users/SavageTiger/events{/privacy}",
              "followers_url" => "https://api.github.com/users/SavageTiger/followers",
              "following_url" => "https://api.github.com/users/SavageTiger/following{/other_user}",
              "gists_url" => "https://api.github.com/users/SavageTiger/gists{/gist_id}"
            }
          ],
          "assignees" => [],
          "merged_at" => "2021-10-08T10:24:22Z",
          "review_comments_url" => "https://api.github.com/repos/Org/Repo/pulls/22033/comments",
          "assignee" => nil,
          "diff_url" => "https://github.com/Org/Repo/pull/22033.diff",
          "author_association" => "CONTRIBUTOR"
        },
        "review" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/Repo/pull/22033#pullrequestreview-774848552"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22033"
            }
          },
          "author_association" => "CONTRIBUTOR",
          "body" => nil,
          "commit_id" => "79bbabc1512033f1bff8790c712d69996f2377a7",
          "html_url" => "https://github.com/Org/Repo/pull/22033#pullrequestreview-774848552",
          "id" => 774_848_552,
          "node_id" => "PRR_kwDOAGZWp84uL0Ao",
          "pull_request_url" => "https://api.github.com/repos/Org/Repo/pulls/22033",
          "state" => "commented",
          "submitted_at" => "2021-10-08T10:25:22Z",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla",
            "node_id" => "MDQ6VXNlcjEzMzgzMg=="
          }
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 6_706_855,
        "name" => "Org/Repo",
        "url" => "https://api.github.com/repos/Org/Repo"
      },
      "type" => "PullRequestReviewEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T10:06:47Z",
      "id" => "18349028633",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "pull_request" => %{
          "title" => "Performance fix",
          "id" => 705_417_020,
          "locked" => false,
          "number" => 21_678,
          "active_lock_reason" => nil,
          "node_id" => "MDExOlB1bGxSZXF1ZXN0NzA1NDE3MDIw",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/104180?v=4",
            "events_url" => "https://api.github.com/users/username/events{/privacy}",
            "followers_url" => "https://api.github.com/users/username/followers",
            "following_url" => "https://api.github.com/users/username/following{/other_user}",
            "gists_url" => "https://api.github.com/users/username/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/username",
            "id" => 104_180,
            "login" => "username",
            "node_id" => "MDQ6VXNlcjEwNDE4MA==",
            "organizations_url" => "https://api.github.com/users/username/orgs",
            "received_events_url" => "https://api.github.com/users/username/received_events",
            "repos_url" => "https://api.github.com/users/username/repos"
          },
          "body" => "Some message",
          "url" => "https://api.github.com/repos/Org/Repo/pulls/21678",
          "statuses_url" => "https://api.github.com/repos/Org/Repo/statuses/3917238c162063e110e694ae5eaeef7887654da7",
          "closed_at" => nil,
          "updated_at" => "2021-10-08T10:06:46Z",
          "created_at" => "2021-08-06T11:39:42Z",
          "html_url" => "https://github.com/Org/Repo/pull/21678",
          "requested_reviewers" => [
            %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/1238070?v=4",
              "events_url" => "https://api.github.com/users/SavageTiger/events{/privacy}",
              "followers_url" => "https://api.github.com/users/SavageTiger/followers",
              "following_url" => "https://api.github.com/users/SavageTiger/following{/other_user}"
            },
            %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/4119451?v=4",
              "events_url" => "https://api.github.com/users/jerowork/events{/privacy}",
              "followers_url" => "https://api.github.com/users/jerowork/followers"
            }
          ],
          "assignees" => [],
          "merged_at" => nil,
          "review_comments_url" => "https://api.github.com/repos/Org/Repo/pulls/21678/comments",
          "assignee" => nil,
          "diff_url" => "https://github.com/Org/Repo/pull/21678.diff"
        },
        "review" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/Repo/pull/21678#pullrequestreview-774832510"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/21678"
            }
          },
          "author_association" => "CONTRIBUTOR",
          "body" => "",
          "commit_id" => "3917238c162063e110e694ae5eaeef7887654da7",
          "html_url" => "https://github.com/Org/Repo/pull/21678#pullrequestreview-774832510",
          "id" => 774_832_510,
          "node_id" => "PRR_kwDOAGZWp84uLwF-",
          "pull_request_url" => "https://api.github.com/repos/Org/Repo/pulls/21678",
          "state" => "approved",
          "submitted_at" => "2021-10-08T10:06:46Z",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832,
            "login" => "userbla"
          }
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 6_706_855,
        "name" => "Org/Repo",
        "url" => "https://api.github.com/repos/Org/Repo"
      },
      "type" => "PullRequestReviewEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T10:03:37Z",
      "id" => "18348981850",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "pull_request" => %{
          "title" => "Some title",
          "id" => 753_883_893,
          "locked" => false,
          "number" => 22_033,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOAGZWp84s71r1",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/104180?v=4",
            "events_url" => "https://api.github.com/users/username/events{/privacy}",
            "followers_url" => "https://api.github.com/users/username/followers",
            "following_url" => "https://api.github.com/users/username/following{/other_user}",
            "gists_url" => "https://api.github.com/users/username/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/username",
            "id" => 104_180,
            "login" => "username",
            "node_id" => "MDQ6VXNlcjEwNDE4MA==",
            "organizations_url" => "https://api.github.com/users/username/orgs",
            "received_events_url" => "https://api.github.com/users/username/received_events"
          },
          "body" => "Fixed config",
          "url" => "https://api.github.com/repos/Org/Repo/pulls/22033",
          "statuses_url" => "https://api.github.com/repos/Org/Repo/statuses/79bbabc1512033f1bff8790c712d69996f2377a7",
          "closed_at" => nil,
          "updated_at" => "2021-10-08T10:03:36Z",
          "created_at" => "2021-10-08T09:49:36Z",
          "html_url" => "https://github.com/Org/Repo/pull/22033",
          "requested_reviewers" => [
            %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/1238070?v=4",
              "events_url" => "https://api.github.com/users/SavageTiger/events{/privacy}",
              "followers_url" => "https://api.github.com/users/SavageTiger/followers"
            }
          ],
          "assignees" => [],
          "merged_at" => nil,
          "review_comments_url" => "https://api.github.com/repos/Org/Repo/pulls/22033/comments",
          "assignee" => nil
        },
        "review" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/Repo/pull/22033#pullrequestreview-774829582"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22033"
            }
          },
          "author_association" => "CONTRIBUTOR",
          "body" => "",
          "commit_id" => "79bbabc1512033f1bff8790c712d69996f2377a7",
          "html_url" => "https://github.com/Org/Repo/pull/22033#pullrequestreview-774829582",
          "id" => 774_829_582,
          "node_id" => "PRR_kwDOAGZWp84uLvYO",
          "pull_request_url" => "https://api.github.com/repos/Org/Repo/pulls/22033",
          "state" => "approved",
          "submitted_at" => "2021-10-08T10:03:36Z",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/userbla",
            "id" => 133_832
          }
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 6_706_855,
        "name" => "Org/Repo",
        "url" => "https://api.github.com/repos/Org/Repo"
      },
      "type" => "PullRequestReviewEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T10:03:15Z",
      "id" => "18348976839",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "comment" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/Repo/pull/22033#discussion_r724878433"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22033"
            },
            "self" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/comments/724878433"
            }
          },
          "author_association" => "CONTRIBUTOR",
          "body" => "Nice!",
          "commit_id" => "79bbabc1512033f1bff8790c712d69996f2377a7",
          "created_at" => "2021-10-08T10:03:15Z",
          "diff_hunk" => "",
          "html_url" => "https://github.com/Org/Repo/pull/22033#discussion_r724878433",
          "id" => 724_878_433,
          "line" => 32,
          "node_id" => "PRRC_kwDOAGZWp84rNMRh",
          "original_commit_id" => "79bbabc1512033f1bff8790c712d69996f2377a7",
          "original_line" => 32,
          "original_position" => 32,
          "original_start_line" => nil,
          "path" => "somepath",
          "position" => 32,
          "pull_request_review_id" => 774_829_277,
          "pull_request_url" => "https://api.github.com/repos/Org/Repo/pulls/22033",
          "reactions" => %{}
        },
        "pull_request" => %{
          "title" => "Some title",
          "id" => 753_883_893,
          "locked" => false,
          "number" => 22_033,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOAGZWp84s71r1",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/104180?v=4",
            "events_url" => "https://api.github.com/users/username/events{/privacy}",
            "followers_url" => "https://api.github.com/users/username/followers",
            "following_url" => "https://api.github.com/users/username/following{/other_user}",
            "gists_url" => "https://api.github.com/users/username/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/username",
            "id" => 104_180,
            "login" => "username",
            "node_id" => "MDQ6VXNlcjEwNDE4MA=="
          },
          "body" => "Fixed config",
          "url" => "https://api.github.com/repos/Org/Repo/pulls/22033",
          "statuses_url" => "https://api.github.com/repos/Org/Repo/statuses/79bbabc1512033f1bff8790c712d69996f2377a7",
          "closed_at" => nil,
          "updated_at" => "2021-10-08T10:03:16Z",
          "created_at" => "2021-10-08T09:49:36Z",
          "html_url" => "https://github.com/Org/Repo/pull/22033",
          "requested_reviewers" => [
            %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/1238070?v=4"
            }
          ],
          "assignees" => [],
          "merged_at" => nil
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 6_706_855,
        "name" => "Org/Repo",
        "url" => "https://api.github.com/repos/Org/Repo"
      },
      "type" => "PullRequestReviewCommentEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
        "display_login" => "userbla",
        "gravatar_id" => "",
        "id" => 133_832,
        "login" => "userbla",
        "url" => "https://api.github.com/users/userbla"
      },
      "created_at" => "2021-10-08T10:03:16Z",
      "id" => "18348976827",
      "org" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
        "gravatar_id" => "",
        "id" => 5_766_233,
        "login" => "Org",
        "url" => "https://api.github.com/orgs/Org"
      },
      "payload" => %{
        "action" => "created",
        "pull_request" => %{
          "title" => "Some title",
          "id" => 753_883_893,
          "locked" => false,
          "number" => 22_033,
          "active_lock_reason" => nil,
          "node_id" => "PR_kwDOAGZWp84s71r1",
          "requested_teams" => [],
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/104180?v=4",
            "events_url" => "https://api.github.com/users/username/events{/privacy}",
            "followers_url" => "https://api.github.com/users/username/followers",
            "following_url" => "https://api.github.com/users/username/following{/other_user}",
            "gists_url" => "https://api.github.com/users/username/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/username",
            "id" => 104_180,
            "login" => "username",
            "node_id" => "MDQ6VXNlcjEwNDE4MA=="
          },
          "body" => "Fixed config",
          "url" => "https://api.github.com/repos/Org/Repo/pulls/22033",
          "statuses_url" => "https://api.github.com/repos/Org/Repo/statuses/79bbabc1512033f1bff8790c712d69996f2377a7",
          "closed_at" => nil,
          "updated_at" => "2021-10-08T10:03:16Z",
          "created_at" => "2021-10-08T09:49:36Z",
          "html_url" => "https://github.com/Org/Repo/pull/22033",
          "requested_reviewers" => [
            %{
              "avatar_url" => "https://avatars.githubusercontent.com/u/1238070?v=4"
            }
          ],
          "assignees" => [],
          "merged_at" => nil
        },
        "review" => %{
          "_links" => %{
            "html" => %{
              "href" => "https://github.com/Org/Repo/pull/22033#pullrequestreview-774829277"
            },
            "pull_request" => %{
              "href" => "https://api.github.com/repos/Org/Repo/pulls/22033"
            }
          },
          "author_association" => "CONTRIBUTOR",
          "body" => nil,
          "commit_id" => "79bbabc1512033f1bff8790c712d69996f2377a7",
          "html_url" => "https://github.com/Org/Repo/pull/22033#pullrequestreview-774829277",
          "id" => 774_829_277,
          "node_id" => "PRR_kwDOAGZWp84uLvTd",
          "pull_request_url" => "https://api.github.com/repos/Org/Repo/pulls/22033",
          "state" => "commented",
          "submitted_at" => "2021-10-08T10:03:16Z",
          "user" => %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
            "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
            "followers_url" => "https://api.github.com/users/userbla/followers",
            "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
            "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
            "gravatar_id" => ""
          }
        }
      },
      "public" => false,
      "repo" => %{
        "id" => 6_706_855,
        "name" => "Org/Repo",
        "url" => "https://api.github.com/repos/Org/Repo"
      },
      "type" => "PullRequestReviewEvent"
    }
  ]

  @pull_request_event_open %{
    "actor" => %{
      "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
      "display_login" => "userbla",
      "gravatar_id" => "",
      "id" => 133_832,
      "login" => "userbla",
      "url" => "https://api.github.com/users/userbla"
    },
    "created_at" => "2021-10-12T07:57:17Z",
    "id" => "18392721055",
    "org" => %{
      "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
      "gravatar_id" => "",
      "id" => 5_766_233,
      "login" => "Org",
      "url" => "https://api.github.com/orgs/Org"
    },
    "payload" => %{
      "action" => "opened",
      "number" => 22_060,
      "pull_request" => %{
        "additions" => 1,
        "title" => "Fix things",
        "comments" => 0,
        "id" => 755_914_775,
        "merged_by" => nil,
        "locked" => false,
        "number" => 22_060,
        "active_lock_reason" => nil,
        "node_id" => "PR_kwDOAGZWp84tDlgX",
        "requested_teams" => [],
        "mergeable" => nil,
        "maintainer_can_modify" => false,
        "user" => %{
          "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
          "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
          "followers_url" => "https://api.github.com/users/userbla/followers",
          "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
          "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
          "gravatar_id" => "",
          "html_url" => "https://github.com/userbla",
          "id" => 133_832,
          "login" => "userbla",
          "node_id" => "MDQ6VXNlcjEzMzgzMg==",
          "organizations_url" => "https://api.github.com/users/userbla/orgs",
          "received_events_url" => "https://api.github.com/users/userbla/received_events",
          "repos_url" => "https://api.github.com/users/userbla/repos",
          "site_admin" => false,
          "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
          "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions",
          "type" => "User",
          "url" => "https://api.github.com/users/userbla"
        },
        "body" => "Some description",
        "url" => "https://api.github.com/repos/Org/Repo/pulls/22060",
        "statuses_url" => "https://api.github.com/repos/Org/Repo/statuses/7b0bd8b8dbd1e9f787522fe9525c8d8b7d0f2489",
        "closed_at" => nil,
        "updated_at" => "2021-10-12T07:57:17Z",
        "created_at" => "2021-10-12T07:57:17Z",
        "html_url" => "https://github.com/Org/Repo/pull/22060",
        "rebaseable" => nil,
        "requested_reviewers" => [
          %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/104180?v=4",
            "events_url" => "https://api.github.com/users/username/events{/privacy}",
            "followers_url" => "https://api.github.com/users/username/followers",
            "following_url" => "https://api.github.com/users/username/following{/other_user}",
            "gists_url" => "https://api.github.com/users/username/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/username",
            "id" => 104_180,
            "login" => "username",
            "node_id" => "MDQ6VXNlcjEwNDE4MA==",
            "organizations_url" => "https://api.github.com/users/username/orgs",
            "received_events_url" => "https://api.github.com/users/username/received_events",
            "repos_url" => "https://api.github.com/users/username/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/username/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/username/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/username"
          },
          %{
            "avatar_url" => "https://avatars.githubusercontent.com/u/28565699?v=4",
            "events_url" => "https://api.github.com/users/janavenkat/events{/privacy}",
            "followers_url" => "https://api.github.com/users/janavenkat/followers",
            "following_url" => "https://api.github.com/users/janavenkat/following{/other_user}",
            "gists_url" => "https://api.github.com/users/janavenkat/gists{/gist_id}",
            "gravatar_id" => "",
            "html_url" => "https://github.com/janavenkat",
            "id" => 28_565_699,
            "login" => "janavenkat",
            "node_id" => "MDQ6VXNlcjI4NTY1Njk5",
            "organizations_url" => "https://api.github.com/users/janavenkat/orgs",
            "received_events_url" => "https://api.github.com/users/janavenkat/received_events",
            "repos_url" => "https://api.github.com/users/janavenkat/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/janavenkat/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/janavenkat/subscriptions",
            "type" => "User",
            "url" => "https://api.github.com/users/janavenkat"
          }
        ],
        "assignees" => [],
        "merged_at" => nil,
        "review_comments" => 0,
        "review_comments_url" => "https://api.github.com/repos/Org/Repo/pulls/22060/comments",
        "assignee" => nil,
        "diff_url" => "https://github.com/Org/Repo/pull/22060.diff",
        "author_association" => "CONTRIBUTOR",
        "patch_url" => "https://github.com/Org/Repo/pull/22060.patch",
        "milestone" => nil,
        "merged" => false,
        "draft" => false,
        "auto_merge" => nil,
        "deletions" => 1,
        "changed_files" => 1,
        "merge_commit_sha" => nil,
        "issue_url" => "https://api.github.com/repos/Org/Repo/issues/22060",
        "base" => %{
          "label" => "Org:main",
          "ref" => "main",
          "repo" => %{}
        },
        "comments_url" => "https://api.github.com/repos/Org/Repo/issues/22060/comments",
        "commits" => 1,
        "commits_url" => "https://api.github.com/repos/Org/Repo/pulls/22060/commits"
      }
    },
    "public" => false,
    "repo" => %{
      "id" => 6_706_855,
      "name" => "Org/Repo",
      "url" => "https://api.github.com/repos/Org/Repo"
    },
    "type" => "PullRequestEvent"
  }

  @pull_request_event_merged %{
    "actor" => %{
      "avatar_url" => "https://avatars.githubusercontent.com/u/133832?",
      "display_login" => "userbla",
      "gravatar_id" => "",
      "id" => 133_832,
      "login" => "userbla",
      "url" => "https://api.github.com/users/userbla"
    },
    "created_at" => "2021-10-12T08:00:05Z",
    "id" => "18392762398",
    "org" => %{
      "avatar_url" => "https://avatars.githubusercontent.com/u/123456?",
      "gravatar_id" => "",
      "id" => 5_766_233,
      "login" => "Org",
      "url" => "https://api.github.com/orgs/Org"
    },
    "payload" => %{
      "action" => "closed",
      "number" => 22_060,
      "pull_request" => %{
        "additions" => 1,
        "title" => "Fix things",
        "comments" => 1,
        "id" => 755_914_775,
        "merged_by" => %{
          "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
          "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
          "followers_url" => "https://api.github.com/users/userbla/followers",
          "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
          "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
          "gravatar_id" => "",
          "html_url" => "https://github.com/userbla",
          "id" => 133_832,
          "login" => "userbla",
          "node_id" => "MDQ6VXNlcjEzMzgzMg==",
          "organizations_url" => "https://api.github.com/users/userbla/orgs",
          "received_events_url" => "https://api.github.com/users/userbla/received_events",
          "repos_url" => "https://api.github.com/users/userbla/repos",
          "site_admin" => false,
          "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
          "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions",
          "type" => "User",
          "url" => "https://api.github.com/users/userbla"
        },
        "locked" => false,
        "number" => 22_060,
        "active_lock_reason" => nil,
        "node_id" => "PR_kwDOAGZWp84tDlgX",
        "requested_teams" => [],
        "mergeable" => nil,
        "maintainer_can_modify" => false,
        "user" => %{
          "avatar_url" => "https://avatars.githubusercontent.com/u/133832?v=4",
          "events_url" => "https://api.github.com/users/userbla/events{/privacy}",
          "followers_url" => "https://api.github.com/users/userbla/followers",
          "following_url" => "https://api.github.com/users/userbla/following{/other_user}",
          "gists_url" => "https://api.github.com/users/userbla/gists{/gist_id}",
          "gravatar_id" => "",
          "html_url" => "https://github.com/userbla",
          "id" => 133_832,
          "login" => "userbla",
          "node_id" => "MDQ6VXNlcjEzMzgzMg==",
          "organizations_url" => "https://api.github.com/users/userbla/orgs",
          "received_events_url" => "https://api.github.com/users/userbla/received_events",
          "repos_url" => "https://api.github.com/users/userbla/repos",
          "site_admin" => false,
          "starred_url" => "https://api.github.com/users/userbla/starred{/owner}{/repo}",
          "subscriptions_url" => "https://api.github.com/users/userbla/subscriptions",
          "type" => "User",
          "url" => "https://api.github.com/users/userbla"
        },
        "body" => "Some description",
        "url" => "https://api.github.com/repos/Org/Repo/pulls/22060",
        "statuses_url" => "https://api.github.com/repos/Org/Repo/statuses/fffdb37ec08c22f408f8f90b4075fe6d29fa1981",
        "closed_at" => "2021-10-12T08:00:04Z",
        "updated_at" => "2021-10-12T08:00:04Z",
        "created_at" => "2021-10-12T07:57:17Z",
        "html_url" => "https://github.com/Org/Repo/pull/22060",
        "rebaseable" => nil,
        "requested_reviewers" => [],
        "assignees" => [],
        "merged_at" => "2021-10-12T08:00:04Z",
        "review_comments" => 0,
        "review_comments_url" => "https://api.github.com/repos/Org/Repo/pulls/22060/comments",
        "assignee" => nil,
        "diff_url" => "https://github.com/Org/Repo/pull/22060.diff",
        "author_association" => "CONTRIBUTOR",
        "patch_url" => "https://github.com/Org/Repo/pull/22060.patch",
        "milestone" => nil,
        "merged" => true,
        "draft" => false,
        "auto_merge" => nil,
        "deletions" => 1,
        "changed_files" => 1,
        "merge_commit_sha" => "461455e3b86e252192b7534178457d45113c40e7",
        "issue_url" => "https://api.github.com/repos/Org/Repo/issues/22060",
        "base" => %{
          "label" => "Org:main",
          "ref" => "main",
          "repo" => %{}
        },
        "comments_url" => "https://api.github.com/repos/Org/Repo/issues/22060/comments",
        "commits" => 1,
        "commits_url" => "https://api.github.com/repos/Org/Repo/pulls/22060/commits"
      }
    },
    "public" => false,
    "repo" => %{
      "id" => 6_706_855,
      "name" => "Org/Repo",
      "url" => "https://api.github.com/repos/Org/Repo"
    },
    "type" => "PullRequestEvent"
  }

  test "Parses GitHub user" do
    items = GithubImporter.parse(@items, %{"ignore_repos" => ["userbla/notes"]})

    item =
      Enum.find_value(items, fn [body: item] ->
        if item["issue_title"] == "Some title", do: item
      end)

    assert not is_nil(item)
    assert "username" == item["github_user_name"]
  end

  test "Parses GitHub user in comment" do
    items = GithubImporter.parse(@items, %{"ignore_repos" => ["userbla/notes"]})

    item =
      Enum.find_value(items, fn [body: item] ->
        if item["id"] == "github_18352875733", do: item
      end)

    assert not is_nil(item)
    assert "username" == item["github_user_name"]
  end

  test "Parses opening a a pull request" do
    items = GithubImporter.parse([@pull_request_event_open], %{"ignore_repos" => ["userbla/notes"]})

    item =
      Enum.find_value(items, fn [body: item] ->
        if item["id"] == "github_18392721055", do: item
      end)

    assert(not is_nil(item))
    assert "Org/Repo" == item["repo_name"]
    assert "userbla" == item["github_user_name"]
    assert "requested" == item["verb"]
  end

  test "Parses merging a a pull request" do
    items = GithubImporter.parse([@pull_request_event_merged], %{"ignore_repos" => ["userbla/notes"]})

    item =
      Enum.find_value(items, fn [body: item] ->
        if item["id"] == "github_18392762398", do: item
      end)

    assert(not is_nil(item))
    assert "Org/Repo" == item["repo_name"]
    assert "merged" == item["verb"]
  end
end
