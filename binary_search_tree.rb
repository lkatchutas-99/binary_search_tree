require "pry-byebug"

class Node
  include Comparable

  attr_accessor :data, :left, :right
  def initialize(data)
    @data = data
    @left = left
    @right = right
  end

  def ==(rhs)
    data == rhs.data
  end

  def >(rhs)
    data > rhs.data
  end
end

class Tree
  attr_reader :root
  def initialize(arr)
    @root = build_tree(arr)
  end

  def build_tree(arr)
    return nil if arr.length.zero?
    
    arr = arr.uniq.sort unless arr.nil?
    root = arr.length/2
    node = Node.new(arr[root])
    node.left = build_tree(arr[0...root])
    node.right = build_tree(arr[root+1...arr.length])
    node
  end

  def insert(value, node = @root)
    if node.nil?
      Node.new(value)
    elsif value > node.data
      node.right = insert(value, node.right)
      node
    elsif value < node.data
      node.left = insert(value, node.left)
      node
    end
  end

  def delete(value, node = @root)
    if node.data == value
      node = node_to_be_deleted(node)
      node
    elsif value > node.data
      node.right = delete(value, node.right)
      node
    else
      node.left = delete(value, node.left)
      node
    end
  end

  def node_to_be_deleted(node)
    if node.left.nil? && node.right.nil?
      node = nil
    elsif node.left.nil? && node.right
      node = node.right
    elsif node.left && node.right.nil?
      node = node.left
    else
      node.data = get_next_highest_node(node.right)
      node.right = shift_nodes(node.right)
    end
    node
  end

  def get_next_highest_node(node)
    if node.left.nil?
      node.data
    else
      get_next_highest_node(node.left)
    end
  end

  def shift_nodes(node)
    if node.left.nil?
      node.right
    else
      node.left = shift_nodes(node.left)
      node
    end
  end

  def find(value, node = @root)
    return if node.nil?

    if node.data == value
      node
    elsif value > node.data
      find(value, node.right)
    else
      find(value, node.left)
    end
  end

  def level_order(node = @root)
    return if node.nil?

    arr = []
    nodes_found = []
    arr.push node
    until arr.empty?
      node = arr.shift
      yield node if block_given?
      nodes_found.push(node.data)
      arr.push(node.left) unless node.left.nil?
      arr.push(node.right) unless node.right.nil?
    end
    nodes_found
  end

  def inorder(node = @root)
    return if node.nil?

    nodes_found = []
    nodes_found.push(inorder(node.left)) unless inorder(node.left).nil?
    nodes_found.push(node.data)
    yield(node) if block_given?
    nodes_found.push(inorder(node.right)) unless inorder(node.right).nil?
    nodes_found.flatten
  end

  def preorder(node = @root)
    return if node.nil?

    nodes_found = []
    nodes_found.push(node.data)
    yield(node) if block_given?
    nodes_found.push(preorder(node.left)) unless preorder(node.left).nil?
    nodes_found.push(preorder(node.right)) unless preorder(node.right).nil?
    nodes_found.flatten
  end

  def postorder(node = @root)
    return if node.nil?

    nodes_found = []
    nodes_found.push(postorder(node.left)) unless postorder(node.left).nil?
    nodes_found.push(postorder(node.right)) unless postorder(node.right).nil?
    nodes_found.push(node.data)
    yield node if block_given?
    nodes_found.flatten
  end

  def height(node)
    return -1 if node.nil?
    
    lnum = height(node.left)
    rnum = height(node.right)
    
    lnum > rnum ? lnum + 1 : rnum + 1
  end

  def depth(node, current_node = @root)
    return if node.nil?
  
    num = -1 
    unless node.data == current_node.data
      if node.data > current_node.data
        num = depth(node, current_node.right)
      else
        num = depth(node, current_node.left)
      end
    end
    num + 1
  end

  def balanced?
    if (height(@root.left) >= height(@root.right))
      height(@root.left) - height(@root.right) <= 1
    else
      height(@root.right) - height(@root.left) <= 1
    end
  end

  def rebalance
    return if balanced?

    @root = build_tree(level_order)
  end  

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end
end

