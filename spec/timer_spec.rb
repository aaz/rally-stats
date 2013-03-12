require 'timer'

describe 'Timer' do
  describe 'with a weekend between In-Progress and Complete' do
    friday = "2013-03-01T10:00:00"
    wednesday = "2013-03-06T10:00:00"
    timeline = [
      [friday, 'In-Progress'],
      [wednesday, 'Completed']
    ]
    it 'should exclude the weekend from cycle time' do
      cycle_time(timeline).should eql 72.0
    end
  end
  describe 'with simple In-Progress -> Complete timeline' do
    timeline = [
      ["2012-02-13T16:15:49", 'In-Progress'],
      ["2012-02-13T18:15:49", 'Completed']
    ]
    it 'should return difference between In-Progress and Completed' do
      cycle_time(timeline).should eql 2.0
    end
  end
  describe 'with sub-hour blocked time' do
    timeline = [
      ["2012-02-13T09:05:30", 'In-Progress'],
      ["2012-02-13T09:15:49", 'Completed']
    ]
    it 'should return the time difference rounded to 1 decimal place' do
      cycle_time(timeline).should eql 0.2
    end
  end
  describe 'with interrupted In-Progress -> Complete timeline' do
    timeline = [
      ["2012-02-13T16:15:49", 'In-Progress'],
      ["2012-02-13T17:15:49", 'Blocked'],
      ["2012-02-13T17:45:49", 'Unblocked'],
      ["2012-02-13T18:15:49", 'Completed']
    ]
    it 'should subtract blocked time' do
      cycle_time(timeline).should eql 1.5
    end
  end
  describe 'with blocked preceding In-Progress -> Complete timeline' do
    timeline = [
      ["2012-02-13T16:15:49", 'Blocked'],
      ["2012-02-13T17:15:49", 'Unblocked'],
      ["2012-02-13T17:45:49", 'In-Progress'],
      ["2012-02-13T18:15:49", 'Completed']
    ]
    it 'should ignore blocked time' do
      cycle_time(timeline).should eql 0.5
    end
  end
end
