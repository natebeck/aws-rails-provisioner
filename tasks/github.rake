task 'github:require-access-token' do
  unless ENV['AWS_SDK_FOR_RUBY_GH_TOKEN']
    warn("export ENV['AWS_SDK_FOR_RUBY_GH_TOKEN']")
    exit
  end
end

task 'github:release' do
  require 'octokit'

  gh = Octokit::Client.new(access_token: ENV['AWS_SDK_FOR_RUBY_GH_TOKEN'])

  repo = 'awslabs/aws-rails-provisioner'
  tag_ref_sha = `git show-ref v#{$VERSION}`.split(' ').first
  tag = gh.tag(repo, tag_ref_sha)

  release = gh.create_release(repo, "v#{$VERSION}", {
    name: 'Release v' + $VERSION + ' - ' + tag.tagger.date.strftime('%Y-%m-%d'),
    body: tag.message + "\n" + `rake changelog:latest`,
    prerelease: $VERSION.match('rc') ? true : false,
  })

  gh.upload_asset(release.url, 'docs.zip',
    :content_type => 'application/octet-stream')

  gh.upload_asset(release.url, "aws-rails-provisioner-#{$VERSION}.gem",
    :content_type => 'application/octet-stream')

end

task 'github:access_token'
