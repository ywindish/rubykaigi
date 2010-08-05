class EventLoader
  # rubyist & event
  # day: 27, 28 or 29
  # from, to: HH:MM
  def self.create(values)
    title, title_ja, abstract, abstract_ja, speaker, room, day, is_break, length, lang, parent_event, profile, profile_ja  = values[:title], values[:title_ja], values[:abstract], values[:abstract_ja], values[:speaker], values[:room], values[:day], (values[:break] || false), (values[:length] || 30.minutes), (values[:lang] || 'en'), values[:parent_event], values[:profile], values[:profile_ja]
    date = "2010/8/#{day}"
    from = values[:from] ? Time.zone.parse("#{date} #{values[:from]}") : Event.at(room).on(date).scoped(:order => 'start_at').last.to
    to = values[:to] ? Time.zone.parse("#{date} #{values[:to]}") : length.since(from)

    event = Event.create :presenter_name => speaker, :presenter_profile_en => profile, :presenter_profile_ja => profile_ja || profile, :title_en => title, :title_ja => title_ja || title, :abstract_en => abstract, :abstract_ja => abstract_ja || abstract, :additional_info => 'あとでかく', :lang => lang, :break => is_break, :parent_event => parent_event
#TODO Rubyistとの紐付けはあとで考える
=begin
    if speaker
      rubyist = Rubyist.find_or_create_by_username speaker
      EventRubyist.create :event => event, :rubyist => rubyist
    end
=end
    EventRoom.create :event => event, :room => room
    (from..30.minutes.until(to)).step(30.minutes) do |t|
      EventTimeSlit.create :event => event, :time_slit => TimeSlit.find_by_start_at(t)
    end

    return event
  end

  def self.create_break(values)
    create values.merge(:title => 'Break', :break => true)
  end
end
