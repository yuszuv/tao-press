class RateLimit
  def initialize(start_time, per_minute: 3, per_day: 200, processed_items: 0)
    @start_time = start_time
    @per_minute = per_minute
    @per_day = per_day
    @processed_items = processed_items
  end

  def call(item)
    wait_if_needed
    item.tap { @processed_items += 1 }
  end

  private

  def wait_if_needed
    current_time = Time.now

    if minute_limit_exceeded?(current_time)
      sleep_time = 60 - (current_time - @start_time) % 60
      puts "Minute limit exceeded. Waiting #{sleep_time.round(1)} seconds..."
      sleep(sleep_time)
    end

    if day_limit_exceeded?(current_time)
      sleep_time = seconds_until_next_day(current_time)
      puts "Daily limit exceeded. Waiting #{sleep_time.round(1)} seconds until next day..."
      sleep(sleep_time)
    end
  end

  def minute_limit_exceeded?(current_time)
    current_minute = current_time.to_i / 60
    start_minute = @start_time.to_i / 60

    # you can process @per_minute items already in the first minute, hence the +1
    @processed_items >= @per_minute * (current_minute - start_minute + 1)
  end

  def day_limit_exceeded?(current_time)
    current_day = current_time.to_i / (60*24)
    start_day = @start_time.to_i / (60*24)

    # you can process @per_minute items already in the first day, hence the +1
    @processed_items >= @per_day * (current_day - start_day + 1)
  end

  def seconds_until_next_day(current_time)
    seconds_per_day = 60*60*24
    seconds_today = current_time.to_i % seconds_per_day

    seconds_per_day - seconds_today
  end
end


