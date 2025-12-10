/**
 * @description Universal trigger for Account object
 * This is the ONLY trigger you need per object
 * All logic is delegated to the TriggerHandler framework
 */
trigger AccountTrigger on Account(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  new TriggerHandler().run();
}