Graph = Object:extend()
function Graph:init()
  self.adjacency_list = {}
  self.nodes = {}
  self.edges = {}
  self.floyd_dists = {}
end


-- Nodes can be of any type but must be unique
-- graph = Graph()
-- graph:add_node(1)
-- graph:add_node('node_2')
function Graph:add_node(node)
  self.adjacency_list[node] = {}
  self:_set_nodes()
end


-- Returns a node after searching for it by property, the property value must be unique among all nodes
-- graph = Graph()
-- graph:add_node({id = 1})
-- graph:add_node({id = 2})
-- graph:get_node_by_property('id', 1) -> original {id = 1} table
function Graph:get_node_by_property(key, value)
  for node, _ in pairs(self.adjacency_list) do
    if node[key] == value then
      return node
    end
  end
end


-- Runs function f for all nodes in the graph
-- graph = Graph()
-- graph:add_node(1)
-- graph:add_node('node_2')
-- graph:for_all_nodes(function(node) print(node) end) -> prints 1, 'node_2'
function Graph:for_all_nodes(f)
  for _, node in ipairs(self.nodes) do
    f(node)
  end
end


-- Runs function f for all edges in the graph
-- graph = Graph()
-- graph:add_node(1)
-- graph:add_node('node_2')
-- graph:add_node(3)
-- graph:add_edge(1, 'node_2')
-- graph:add_edge('node_2', 3)
-- graph:for_all_edges(function(node1, node2) print(node1, node2) end) -> prints 1, 'node_2'; prints 'node_2', 3
function Graph:for_all_edges(f)
  for _, edge in ipairs(self.edges) do
    f(edge[1], edge[2])
  end
end


-- Returns a table containing all neighbors of the given node.
-- graph = Graph()
-- graph:add_node(1)
-- graph:add_node('node_2')
-- graph:add_node(3)
-- graph:add_edge(1, 'node_2')
-- graph:add_edge('node_2', 3)
-- graph:get_node_neighbors('node_2') -> {1, 3}
function Graph:get_node_neighbors(node)
  return self.adjacency_list[node]
end


-- graph = Graph()
-- graph:add_node(1)
-- graph:remove_node(1)
function Graph:remove_node(node)
  for _node, list in pairs(self.adjacency_list) do
    self:remove_edge(node, _node)
  end
  self.adjacency_list[node] = nil
  self:_set_nodes()
end


local function contains_edge(table, edge)
  for _, v in ipairs(table) do
    if (v[1] == edge[1] and v[2] == edge[2]) or (v[1] == edge[2] and v[2] == edge[1]) then
      return true
    end
  end
  return false
end


-- graph = Graph()
-- graph:add_node(1)
-- graph:add_node('node_2')
-- graph:add_edge(1, 'node_2')
function Graph:add_edge(node1, node2)
  if table.any(self.adjacency_list[node1], function(v) return v == node2 end) then return end
  table.insert(self.adjacency_list[node1], node2)
  table.insert(self.adjacency_list[node2], node1)
  self:_set_edges()
end


-- graph = Graph()
-- graph:add_node(1)
-- graph:add_node('node_2')
-- graph:add_edge(1, 'node_2')
-- graph:remove_edge(1, 'node_2')
function Graph:remove_edge(node1, node2)
  for i, node in ipairs(self.adjacency_list[node1]) do
    if node == node2 then
      table.remove(self.adjacency_list[node1], i)
      break
    end
  end
  for i, node in ipairs(self.adjacency_list[node2]) do
    if node == node1 then
      table.remove(self.adjacency_list[node2], i)
      break
    end
  end
  self:_set_edges()
end


-- graph = Graph()
-- graph:add_node(1)
-- graph:add_node('node_2')
-- graph:add_node('node_3')
-- graph:add_edge(1, 'node_2')
-- graph:add_edge('node_2', 'node_3')
-- path = graph:shortest_path_bfs(1, 'node_3')
-- print(path) -> {1, 'node_2', 'node_3'}
function Graph:shortest_path_bfs(node1, node2)
  local path = {}
  local visited = {}
  local queue = {}
  table.insert(queue, node1)
  visited[node1] = true

  while #queue > 0 do
    local node = table.remove(queue, 1)
    if node == node2 then
      local linear_path = {}
      local current_node = node2
      table.insert(linear_path, 1, current_node)
      while current_node ~= node1 do
        current_node = path[current_node]
        table.insert(linear_path, 1, current_node)
      end
      return linear_path
    end

    for _, neighbor in ipairs(self.adjacency_list[node]) do
      if not visited[neighbor] then
        path[neighbor] = node
        visited[neighbor] = true
        table.insert(queue, neighbor)
      end
    end
  end
end


function Graph:get_distance_between_nodes(node1, node2)
  return self.floyd_dists[node1][node2]
end


-- Comments follow pseudocode from http://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm.
-- graph = Graph()
-- graph:add_node(1)
-- graph:add_node('node_2')
-- graph:add_edge(1, 'node_2')
-- graph:floyd_warshall()
-- print(graph.floyd_dists[1]['node_2']) -> 1
function Graph:floyd_warshall()
  self:_set_nodes()
  self:_set_edges()

  -- initialize multidimensional to be array
  for _, node in ipairs(self.nodes) do
    self.floyd_dists[node] = {}
  end

  -- let floyd_dist be a |V|x|V| array of minimun distance initialized to infinity
  for _, node in ipairs(self.nodes) do
    for _, _node in ipairs(self.nodes) do
      self.floyd_dists[node][_node] = 10000 -- 10000 is big enough for an unweighted graph
      self.floyd_dists[_node][node] = 10000
    end
  end

  -- set dist[v][v] to 0
  for _, node in ipairs(self.nodes) do
    self.floyd_dists[node][node] = 0
  end

  -- set dist[u][v] to w(u, v) which is always 1 in the case of an unweighted graph
  for _, edge in ipairs(self.edges) do
    self.floyd_dists[edge[1]][edge[2]] = 1
    self.floyd_dists[edge[2]][edge[1]] = 1
  end

  -- main triple loop
  for _, nodek in ipairs(self.nodes) do
    for _, nodei in ipairs(self.nodes) do
      for _, nodej in ipairs(self.nodes) do
        if self.floyd_dists[nodei][nodek] + self.floyd_dists[nodek][nodej] < self.floyd_dists[nodei][nodej] then
          self.floyd_dists[nodei][nodej] = self.floyd_dists[nodei][nodek] + self.floyd_dists[nodek][nodej]
        end
      end
    end
  end
end


function Graph:_get_edge(node1, node2)
  for _, node in ipairs(self.adjacency_list[node1]) do
    if node == node2 then
      return true
    end
  end
  return false
end


function Graph:_set_nodes()
  self.nodes = {}
  for node, _ in pairs(self.adjacency_list) do
    table.insert(self.nodes, node)
  end
end


function Graph:_set_edges()
  self.edges = {}
  for node, list in pairs(self.adjacency_list) do
    for _, _node in ipairs(list) do
      if not contains_edge(self.edges, {node, _node}) then
        table.insert(self.edges, {node, _node})
      end
    end
  end
end


function Graph:__tostring()
  local str = "----\nAdjacency List: \n"
  for node, list in pairs(self.adjacency_list) do
    str = str .. node .. " ->   "
    for _, adj in ipairs(list) do
      str = str .. adj .. ", "
    end
    str = string.sub(str, 0, -3)
    str = str .. "\n"
  end
  str = str .. "\n"
  str = str .. "Nodes: \n"
  for _, node in ipairs(self.nodes) do
    str = str .. node .. "\n"
  end
  str = str .. "\n"
  str = str .. "Edges: \n"
  for _, edge in ipairs(self.edges) do
    str = str .. edge[1] .. ", " .. edge[2]
    str = str .. "\n"
  end
  str = str .. "\n"
  str = str .. "Floyd Warshall Distances: \n"
  for node, _ in pairs(self.floyd_dists) do
    for _node, _ in pairs(self.floyd_dists[node]) do
      str = str .. "(" .. node .. ", " .. _node .. ") = " .. self.floyd_dists[node][_node]
      str = str .. "\n"
    end
  end
  str = str .. "----\n"
  return str
end
