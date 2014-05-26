require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Browse do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w( browse )).should.be.instance_of Command::Browse
      end

      it 'presents the help if no name is provided' do
        command = Pod::Command.parse(['browse'])
        should.raise CLAide::Help do
          command.validate!
        end.message.should.match /A Pod name is required/
      end

      it 'runs' do
        Config.instance.skip_repo_update = false
        command = Pod::Command.parse(%w(browse iOS-FakeWeb))
        # command.expects(:update_specs_repos)
        command.expects(:specs_with_name)
        command.run
      end
    end
  end
end
