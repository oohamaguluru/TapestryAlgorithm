defmodule Project3 do
  def main(args) do
    if( length(args) < 2) do
      IO.puts "Please specify two arguments"
      exit(:shutdown)
    end
    args_tup=List.to_tuple(args)
    numNodes=String.to_integer(elem(args_tup,0))
    numReq=String.to_integer(elem(args_tup,1))
    IO.puts "numNodes: #{numNodes}"
    IO.puts "numReq: #{numReq}"
    # GenerateHashIds.startAlgo(numNodes, numReq)
    Tapestry.start_link(numNodes,numReq)
    looper()
  end

  def looper() do
    looper()
  end

end

Project3.main(System.argv())