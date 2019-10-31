defmodule Tapestry do
 use Supervisor


def start_link(nnum,rnum) do
nhash=Map.values(generate_node_id(1..nnum))
#IO.inspect(nhash)
nhashnew=[0]++nhash
result=Supervisor.start_link(__MODULE__,[nhash,nnum,rnum,nhashnew],name: String.to_atom("super"))
startchild(nhash,nnum,rnum)
result
end

def init(args) do
children=Enum.map(Enum.at(args,3),fn x -> cond do
                                                    x == 0 ->
                                                    worker(AT,[Enum.at(args,0),Enum.at(args,1),Enum.at(args,2)],[id: x,restart: :temporary]) # assign neighbours using topolgy worker
                                                    true ->
                                                     worker(WA,[x,Enum.at(args,2),Enum.at(args,0)],[id: x,restart: :temporary]) # each one is a new worker who does work based on algo
                                               end
                                               end)
        Supervisor.init(children,strategy: :one_for_one,restart: :temporary)
   
end

def generate_node_id(nrange) do
hashid_map=Enum.reduce(nrange,%{},fn(id,hashid_map) -> (
hash_id=String.pad_leading(Integer.to_string(id, 16),4,"0")
hashid_map=Map.put(hashid_map,id,hash_id)
hashid_map
)end)
end


def startchild(nhash,nnum,rnum) do
            Enum.each(nhash,fn(x) -> 
            GenServer.cast(String.to_atom(x),{:createfriends,nhash,x}) end)
end

end