require File.expand_path('../../spec_helper', __FILE__)

module Pod 

  describe Command::Browser do

    describe "CLAide" do
      it "registers it self" do
        Command.parse(%w{ browser }).should.be.instance_of Command::Browser
      end

      it "presents the help if no name is provided" do
        command = Pod::Command.parse(['browser'])
        should.raise CLAide::Help do
          command.validate!
        end.message.should.match /A Pod name is required/
      end

      it "runs" do
        Config.instance.skip_repo_update = false
        command = Pod::Command.parse(['browser', 'iOS-FakeWeb'])
#         command.expects(:update_specs_repos)
        command.expects(:spec_with_name)
        command.run
      end
    end

  end

end

