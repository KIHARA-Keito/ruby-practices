# frozen_string_literal: true

# ボウリングのスコア計算
scores = ARGV[0].split(/,/)

shots = []
shot_count = 0 # 18以上は10フレーム目
scores.each do |shot|
  if shot == 'X' # strikeの場合
    shots << 10
    if shot_count < 18 # 9フレームまで実行
      shots << 0
      shot_count += 2
    end
  else
    shots << shot.to_i
    shot_count += 1
  end
end

frames = []
shots.each_slice(2) do |i|
  frames << i
end

score_total = 0
frames.each_with_index do |frame, i|
  if frame[0] == 10 && i < 9 # strikeかつ9フレームまでの場合
    next_frames = frames[i + 1] # 次のフレーム取得
    score_total += if next_frames[0] == 10 && i < 8 # 次のフレームもstrikeかつ8フレームまでの場合
                     10 + frames[i + 2][0] # 次の次のフレームからも加算
                   else # 次のフレームがstrikeでない場合
                     next_frames.sum
                   end
  elsif frame.sum == 10 && i < 9 # spareかつ9フレームまでの場合
    score_total += frames[i + 1][0]
  end
  score_total += frame.sum
end

puts score_total
