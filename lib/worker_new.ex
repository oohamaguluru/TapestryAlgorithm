defmodule WA do
  use GenServer

  def start_link(opts,requests,nhash) do
    GenServer.start_link(__MODULE__ ,[opts,requests,nhash],name: String.to_atom((opts)))
  end

  def init(args) do
    counter = 0 
    x = 0
    hashlist=Enum.at(args,2)
    req=Enum.at(args,1)
    hopcount=0
    maxhop=0
    {:ok, {x,[],counter,req,hashlist,hopcount,maxhop}}
  end

def handle_cast({:createfriends,nhash,k},{x,[],counter,req,hashlist,hopcount,maxhop}) do
    p=k
    neilist = getneighbours(p,nhash)
    x=p
    GenServer.cast(String.to_atom(Integer.to_string(0)),{:finish})
    {:noreply, {x,neilist,counter,req,hashlist,hopcount,maxhop}}
  end

  def getneighbours(x,nhash) do
  hexamap = %{"0" => 0, "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" =>5, "6" => 6, "7" => 7, "8" => 8, "9" => 9, "A" => 10, "B" =>11, "C" => 12, "D" => 13, "E" => 14, "F" => 15}
  rvalues=nhash--[x]
 
  rslist=Enum.reduce(rvalues,[["","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","",""]],
  fn(idx,list)
             ->(
                  u=String.graphemes(idx)
                  column=generatelevel(x,idx)
                  lk=Enum.at(list,Enum.at(column,0))
                  lk=List.replace_at(lk,hexamap[(Enum.at(u,Enum.at(column,0)))],idx)
                  list=List.replace_at(list,Enum.at(column,0),lk)
                  list
                  )
  end)

  # IO.puts("#{x} finish calculation")
  rslist
 end


def generatelevel(a,b) do
list=Enum.map(0..7,fn x ->( 
 p=String.graphemes(a)
 q=String.graphemes(b)
if(!(Enum.at(p,x)==Enum.at(q,x))) do
 x
end 
)
end
)
list=Enum.filter(list, & !is_nil(&1))
list
end

    def handle_cast({:startworking,xc},{x,neilist,counter,req,hashlist,hopcount,maxhop}) do
      # IO.inspect(neilist)
      list=Enum.map(1..req,fn(x) ->
                                  rvalues=hashlist--[xc]
                                  Enum.random(rvalues)

      end)
     # IO.puts "list of destinaton are  #{inspect(list)} for #{xc}"
      # IO.inspect("#{xc} is searching for 2")
      Enum.each(list,fn(l)-> 
      hc=0
      GenServer.cast(String.to_atom(xc),{:getdestinationhop,l,hc,xc})
      end)

      {:noreply, {x,neilist,counter,req,hashlist,hopcount,maxhop}}
    end

    def handle_cast({:getdestinationhop,k,hc,xc},{x,neilist,counter,req,hashlist,hopcount,maxhop}) do
             #min=20000
             #flag=0
             #nextdest="0"
             # IO.inspect(neilist)
             # IO.inspect(k)
             hexamap = %{"0" => 0, "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" =>5, "6" => 6, "7" => 7, "8" => 8, "9" => 9, "A" => 10, "B" =>11, "C" => 12, "D" => 13, "E" => 14, "F" => 15}
            rowindex = generatelevel(x,k)
            # IO.inspect(rowindex)
            rowlist =Enum.at(neilist,Enum.at(rowindex,0))
            # IO.inspect(rowlist)
             p=String.graphemes(k)
             col = Enum.at(p,Enum.at(rowindex,0))
             # IO.inspect(col)
            val = Enum.at(rowlist,hexamap[col])

             # r=Enum.map(neilist,fn(p) ->
             #               Enum.any?(1..length(p),fn(h) ->(Enum.at(p,h) == k )end)
             #               end)
             if(val==k) do
              # IO.inspect("direct neighbour")
               hc=hc+1;
               GenServer.cast(String.to_atom(xc),{:founddestination,hc})
             else

                  # IO.inspect("Indirect neighbour #{val}")
               #   b=Enum.concat(neilist)
               #   b=Enum.uniq(b)--[""]
               #   dist=Enum.map(0..(length(b)-1),fn(u) ->(
               #                            elem(Integer.parse(Enum.at(b,u), 16),0)-elem(Integer.parse(x, 16),0)
               #                                  )
               #                end)
               #  index = Enum.find_index(dist,fn(o)-> o == Enum.min(dist) end)
               # nextdest=Enum.at(b,index)
               hc=hc+1
              GenServer.cast(String.to_atom(val),{:getdestinationhop,k,hc,xc})
            end
    {:noreply, {x,neilist,counter,req,hashlist,hopcount,maxhop}}
    end


    def handle_cast({:founddestination,hc},{x,neilist,counter,req,hashlist,hopcount,maxhop}) do
          maxhop = cond do 
                    maxhop < hc -> hc
                    true -> maxhop
                  end
          counter = cond do 
                    req == counter+1 -> GenServer.cast(String.to_atom(Integer.to_string(0)),{:mymaxhop,maxhop})
                    true -> counter+1
                  end
          {:noreply, {x,neilist,counter,req,hashlist,hopcount,maxhop}}        
    end

end 