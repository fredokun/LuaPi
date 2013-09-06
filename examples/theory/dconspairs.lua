require "pithreads"

-- a dynamic version of cons pairs encoded in CCS

function HeadNode(proc, val, cons, cdr, car, next)
   proc:choice(
      {car:send(val), 
       function()
          HeadNode(proc, val, cons, cdr, car, next)
       end},
      {cons:receive(),
       function(nval)
          local link = proc:new("link")
          proc:spawn("NewHead", HeadNode, nval, cons, cdr, car, link)
          Node(proc, val, link, cons, cdr, car, next)
       end},
      {cdr:receive(),
       function()
          proc:signal(next)
       end})()			  
end

function Node(proc, val, prev, cons, cdr, car, next)
   proc:receive(prev)
   HeadNode(proc, val, cons, cdr, car, next)
end

function NilNode(proc, prev)
   proc:receive(prev)
   -- die
end

function MainProc(proc, cons, cdr, car)
   local v = proc:receive(car)
   print(v)

   -- cons 0::cdr
   proc:send(cons, 0)
   v = proc:receive(car)
   print(v)

   -- cdr
   proc:signal(cdr)

   v = proc:receive(car)
   print(v)
end


agent = pithreads.init()

-- L = 1::2::3::nil
      

local L_do_cons = agent:new("L_do_cons")
local L_do_cdr = agent:new("L_do_cdr")
local L_do_car = agent:new("L_do_car")

local one_two = agent:new("one_two")

agent:spawn("One", HeadNode, 1, L_do_cons, L_do_cdr, L_do_car, one_two)

local two_three = agent:new("two_three")

agent:spawn("Two", Node, 2, one_two, L_do_cons, L_do_cdr, L_do_car, two_three)

local three_end = agent:new("three_end")

agent:spawn("Three", Node, 3, two_three, L_do_cons, L_do_cdr, L_do_car, three_end)

agent:spawn("Nil",NilNode, three_end)

agent:spawn("Main", MainProc, L_do_cons, L_do_cdr, L_do_car)

agent:run()

