# frozen_string_literal: true

scores = ARGV[0].split(',')

shots = []
NUMBER_IN_LASTFRAME = 19
scores.each do |shot|
  if shot == 'X'
    shots << 10
    shots << 0 if shots.size < NUMBER_IN_LASTFRAME
  else
    shots << shot.to_i
  end
end

frames = shots.each_slice(2).to_a

def strike?(frame)
  frame[0] == 10
end

def spare?(frame)
  frame.sum == 10
end

score_total = 0
frames.each_with_index do |frame, i|
  if i < 9
    if strike?(frame)
      next_frame = frames[i + 1]
      score_total +=
        if next_frame[0] == 10 && i < 8
          10 + frames[i + 2][0]
        else
          next_frame.sum
        end
    elsif spare?(frame)
      score_total += frames[i + 1][0]
    end
  end
  score_total += frame.sum
end

puts score_total
