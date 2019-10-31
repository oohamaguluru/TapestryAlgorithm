defmodule AT do
  use GenServer

  def start_link(nhash,nnum,rnum) do
    GenServer.start_link(__MODULE__ ,[nhash,nnum,rnum],name: String.to_atom(Integer.to_string(0)))
  end

  def init(args) do
    n = Enum.at(args,1)
    count = 0
    requests=Enum.at(args,2)
    hashlist=Enum.at(args,0)
    time = :os.system_time(:millisecond)
    maxhop = 0
    {:ok, {n,count,time,hashlist,maxhop}}
  end

  def handle_cast({:finish},{n,count,time,hashlist,maxhop}) do
       time =  cond do
            n == count+2 -> 
                     # IO.puts "Casting for hops finshed counting #{count}"
           Enum.each(hashlist,fn(xc) -> 
           GenServer.cast(String.to_atom(xc),{:startworking,xc}) end)
                   :os.system_time(:millisecond)

            true ->
                   #IO.puts("#{count} #{n} final count")
                    :os.system_time(:millisecond)
        end
      {:noreply, {n,count+1,time,hashlist,maxhop}}
      end

      def handle_cast({:mymaxhop,max},{n,count,time,hashlist,maxhop}) do
        maxhop =  cond do
            maxhop < max -> #IO.puts "update maxhop #{max}"
                            max
                      
            true -> #IO.puts "this maxhop #{max} #{count}"
                    maxhop
                   
        end
       count =  cond do
            count == 1 -> IO.puts "max hop is  #{maxhop}"
                          System.stop(0)
                          count
                      
            true -> count-1
                   
        end
      {:noreply, {n,count,time,hashlist,maxhop}}
      end
    end