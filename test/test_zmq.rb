class TestZmq < MiniTest::Test
  @zmq_ctx = nil
  @zmq_push = nil
  @zmq_pull = nil

  def setup
    host = 'tcp://127.0.0.1:2200'

    @zmq_pull = zmq_pull_socket host

    @zmq_ctx = ZMQ::Context.create(1)
    @zmq_push = @zmq_ctx.socket(ZMQ::PUSH)
    @zmq_push.setsockopt(ZMQ::LINGER, 0)
    rc = @zmq_push.connect(host)
  end

  def teardown
    @zmq_pull.close
    @zmq_push.close
    @zmq_ctx.terminate
  end

  should 'create push & pull socket' do
    message = ''

    zmq_pull_once @zmq_pull do |msg|
      # puts "zmq recv: #{msg}"
      message = msg
    end

    rc = @zmq_push.send_string('test')
    if not ZMQ::Util.resultcode_ok?(rc)
      STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
      caller(1).each { |callstack| STDERR.puts(callstack) }
    end

    sleep 0.01

    assert_equal 'test', message
  end

end