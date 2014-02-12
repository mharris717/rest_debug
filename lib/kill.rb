res = `ps -ax | grep ruby`.split("\n").map { |x| x[0..60] }
puts res.join("\n")
res[0...5].each do |line|
  pid = line.split(" ").first
  `kill #{pid}`
end