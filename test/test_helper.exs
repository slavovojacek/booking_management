{:ok, _} = Application.ensure_all_started(:ex_machina)
:ok = MQ.Support.TestConsumerRegistry.init()
ExUnit.start()
