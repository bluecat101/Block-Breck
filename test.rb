# test ={"1": 2,"1"=>3}
# puts test[:"1"]
# puts test["1"]
# p [((3)%8)..((5)%8)].sample

a = 3
p Array.new(3){|i|
case i
when 1
  i
when 2
  20
else
  "f"

end
}