--[[ 

This example is a highly parallel
implementation of the quicksort algorithm.

   Of course, the parallelism is not exploited
by the Lua VM but it is still an interesting
 exercise in "channel-oriented-programming".

--]]

require "pithreads"

LENGTH = tonumber(arg and arg[1]) or 50
MIN = tonumber(arg and arg[2]) or 1
MAX = tonumber(arg and arg[3]) or LENGTH

function Head(proc, nb_links, unlink)
   --print("<Head> started: " .. tostring(nb_links) .. " candidates (unlink=" .. tostring(unlink) .. ")")
   local nb_unlinked = 0
   local first_pivot = nil
   for i = 1, nb_links do
      local unlinked = proc:receive(unlink)
      nb_unlinked = nb_unlinked + 1
      --print("<Head> Unlink: nb unlinked = " ..tostring(nb_unlinked) .. " (unlinked=" .. tostring(unlinked) .. ")")
      if unlinked ~= nil then
         first_pivot = unlinked
      end
   end
   -- all the candidates have been unlinked
   -- time to print the result
   proc:send(first_pivot, 'print')
end

function Pivot(proc, head, prev_, self_, next_, link, val)
   --print("<Pivot> started: val=" .. tostring(val) .. " (link=" .. tostring(link) .. ")")
   while true do
      proc:choice(
         { link:receive(),
           function(link_val)
              --print("<Pivot" ..tostring(val) .. "> link from " ..tostring(link_val))
              if link_val <= val then
                 if prev_ == nil then -- new smaller pivot
                    prev_ = proc:new("self")
                    local prev_link = proc:new("link")
                    proc:send(head, prev_) -- tell the head there is a new smallest pivot
                    proc:yield()
                    proc:spawn("Pivot", Pivot, head, nil, prev_, self_, prev_link, link_val)
                    proc:yield()
                 else
                    proc:send(prev_, 'link_from_next', link_val) -- the previous pivot manage this link
                    proc:yield()
                 end
              elseif next_ == nil then -- new greater pivot
                 proc:signal(head)
                 next_ = proc:new("self")
                 local next_link = proc:new("link")
                 proc:spawn("Pivot", Pivot, head, self_, next_, nil, next_link, link_val)
                 proc:yield()
              else
                 proc:send(next_, 'link_from_prev', link_val) -- the next pivot manage this link
                 proc:yield()
              end
           end
         },
         { self_:receive(),
           function(cmd, value)
              --print("<Pivot" ..tostring(val) .. "> self cmd='" ..tostring(cmd) .. "' value=" ..tostring(value))
              if cmd == 'link_from_next' then
                 local link_val = value
                 if link_val >= val then
                    -- need to create a new pivot in between
                    proc:signal(head)
                    local old_next_ = next_
                    next_ = proc:new("self")
                    local next_link = proc:new("link")
                    proc:spawn("Pivot", Pivot, head, self_, next_, old_next_, next_link, link_val)
                    proc:yield()  -- WARNING: if yield() is removed then there is a 'chicken-and-egg' issue...
                    proc:send(old_next_, 'rebind_prev', next_)
                    proc:yield()
                 else
                    proc:spawn("Candidate", Candidate, link, link_val)
                 end
              elseif cmd == 'rebind_prev' then
                 _prev = value
              elseif cmd == 'link_from_prev' then
                 local link_val = value
                 if link_val <= val then
                    -- need to create a new pivot in between
                    proc:signal(head)
                    proc:yield()
                    local old_prev_ = prev_
                    prev_ = proc:new("self")
                    local prev_link = proc:new("link")
                    proc:spawn("Pivot", Pivot, head, old_prev_, prev_, self_, prev_link, link_val)
                    proc:yield()
                    proc:send(old_prev_, 'rebind_next', prev_)
                    proc:yield()
                 else
                    proc:spawn("Candidate", Candidate, link, link_val)
                    proc:yield()
                 end
              elseif cmd == 'rebind_next' then
                 _next = value
              elseif cmd == 'print' then
                 io.write(tostring(val))
                 if next_ ~= nil then
                    io.write(", ")
                    proc:send(next_, 'print') 
                    proc:yield()
                 else
                    print()  -- add a newline at the end
                 end
              else
                 error("Unrecognized command: '" .. tostring(cmd) .. "'")
              end
           end
         }
      )() -- end of choice

   end -- while
end

function Candidate(proc, link, val)
   --print("<Candidate> started: val = " ..tostring(val) .. " (link=" .. tostring(link) .. ")")
   proc:yield()
   proc:send(link, val)   -- and that's it !
   proc:yield()
end

function PrintTab(tab)
  local str = ""
  for i,elem in ipairs(tab) do
    str = str .. tostring(elem)
    if i<#tab then
      str = str .. ", "
    end
  end
  str = str .. ""
  return str
end

function Main(proc,tab)
  print("Initial:\n" .. tostring(PrintTab(tab)))
  print("Result:")

  -- spawn the head process
  local unlink = proc:new("unlink")
  proc:spawn("Head", Head, #tab, unlink)
  proc:yield()

  -- spawn the first pivot and linked candidates
  local first_pivot = nil
  for idx, val in ipairs(tab) do
     if first_pivot == nil then
        local self_ = proc:new("self")
        first_pivot = proc:new("link")
        proc:spawn("Pivot", Pivot, unlink, nil, self_, nil, first_pivot, val)
        proc:send(unlink, self_)  -- the first pivot must be unlinked
     else
        proc:spawn("Candidate", Candidate, first_pivot, val)
     end
  end
end

local agent = pithreads.init()

--[[ 
-- random array
local tab = {}
for i=1,LENGTH do
  table.insert(tab,math.random(MIN,MAX))
end
--]]

-- debuggable example
local tab = { 3, 2, 5, 4, 1, 7 }

agent:spawn("Main",Main,tab)

agent:run()
