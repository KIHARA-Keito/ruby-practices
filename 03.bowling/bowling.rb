# frozen_string_literal: true

LAST_FRAME_NUMBER = 19
scores = ARGV[0].split(',')

shots = []
scores.each do |shot|
  if shot == 'X'
    shots << 10
    shots << 0 if shots.size < LAST_FRAME_NUMBER
  else
    shots << shot.to_i
  end
end

def strike?(frame)
  frame[0] == 10
end

def spare?(frame)
  !strike?(frame) && frame.sum == 10
end

score_total = 0
frames = shots.each_slice(2).to_a
frames.each_with_index do |frame, i|
  if i < 9
    next_frame = frames[i + 1]
    if strike?(frame)
      score_total +=
        if strike?(next_frame) && i < 8
          10 + frames[i + 2][0]
        else
          next_frame.sum
        end
    elsif spare?(frame)
      score_total += next_frame[0]
    end
  end
  score_total += frame.sum
end

puts score_total
