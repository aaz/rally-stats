require 'highline'
require 'rally_api'
require 'timer'
require 'yaml'

include RallyAPI

STATE_CHANGE = /SCHEDULE STATE changed from \[.*?\] to \[(.*?)\]/
BLOCK_UNBLOCK = /BLOCKED changed from \[.+?\] to \[(.+?)\]/
TIMESTAMP_SUFFIX = /\.[0-9]+Z$/
ID_IN_JSON_URL = /\/([0-9]+)\.js/
HEADINGS = ['Story', 'Estimate', 'In-Progress', 'Completed', 'Accepted', 'Cycle-Time']

config = YAML.load_file "config.yaml"

input = HighLine.new

config[:username] = input.ask("Username: ")
config[:password] = input.ask("Password: ") {|q| q.echo = "*"}

rally = RallyRestJson.new(config)

def find_all_accepted_stories(rally)
  query_hash = {}
  query_hash["ScheduleState"] = "Accepted"
  query = RallyQuery.new(query_hash)
  query.type = "userstory"
  
  stories = rally.find(query)
  stories.collect do |r|
    ref_to_id(r.getref)
  end
end

def ref_to_id(ref)
  id = ID_IN_JSON_URL.match(ref)
  id[1].to_s.to_i
end

accepted_story_ids = find_all_accepted_stories(rally)
rows = Array.new
puts HEADINGS.join(',')

accepted_story_ids.each do |id|
  story = rally.read("story", id)
  next unless (story["ScheduleState"] == "Accepted" && story["Children"].size == 0)

  story_ref = story["FormattedID"]
  estimate = story["PlanEstimate"]
  row = Array.new [story_ref, estimate, nil, nil, nil, 0.0]

  history = story["RevisionHistory"]
  rh_id = ref_to_id(history.getref)
  rh = rally.read("RevisionHistory", rh_id)
  timeline = []
  revs = rh["Revisions"]
  revs.sort.each_entry do |rev|
    revision = []
    timestamp = rev[:CreationDate].sub(TIMESTAMP_SUFFIX, '')
    revision.push timestamp
    if (match = STATE_CHANGE.match rev[:Description]) then
      state = match[1]
      revision.push state
      (row[HEADINGS.rindex(state)] = timestamp) if (HEADINGS.include? state)
    end
    if (match = BLOCK_UNBLOCK.match rev[:Description]) then
      event = match[1] == "true" ? "Blocked" : "Unblocked"
      revision.push event
    end
    timeline.push(revision) unless (revision.size == 1)
  end

  # Not all stories have a sufficient timeline, i.e. one with In-Progress and Completed events
  if ((timeline.rassoc('In-Progress') != nil) && (timeline.rassoc('Completed') != nil)) then
    row[HEADINGS.rindex('Cycle-Time')] = cycle_time(timeline)
  end
  puts row.join(',')
end
