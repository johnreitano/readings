workers Integer(ENV['WEB_CONCURRENCY'] || 0)
threads_count = Integer(ENV['THREAD_COUNT'] || 40)
threads threads_count, threads_count
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'
