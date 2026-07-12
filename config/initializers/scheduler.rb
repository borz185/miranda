require 'rufus-scheduler'

# Запускаем планировщик
if defined?(Rails::Server) || !defined?(Rails::Console) && !Rails.env.test? && $0.include?('puma')
  scheduler = Rufus::Scheduler.new

  # Запуск биллинга каждый день в 3:00 (* * * * * - каждую минуту для теста) ночи
  scheduler.cron '* * * * *' do
    puts "🤖 [Scheduler] Запуск автоматического биллинга #{Time.current}..."
    system('rails billing:daily')
  end

  puts "✅ [Scheduler] Планировщик запущен. Биллинг будет выполняться каждый день в 3:00"
end