describe Fastlane::Actions::FabricBetaUnregisteredDevicesAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The fabric_beta_unregistered_devices plugin is working!")

      Fastlane::Actions::FabricBetaUnregisteredDevicesAction.run(nil)
    end
  end
end
