module Dentaku
  class PrintVisitor
    def initialize(node)
      @output = ''
      node.accept(self)
    end

    def visit_operation(node)
      if node.left
        visit_operand(node.left, node.class.precedence, suffix: node.operator_spacing, dir: :left)
      end

      @output << node.display_operator

      if node.right
        visit_operand(node.right, node.class.precedence, prefix: node.operator_spacing, dir: :right)
      end
    end

    def visit_operand(node, precedence, prefix: "", suffix: "", dir: :none)
      @output << prefix
      @output << "(" if should_output?(node, precedence, dir == :right)
      node.accept(self)
      @output << ")" if should_output?(node, precedence, dir == :right)
      @output << suffix
    end

    def should_output?(node, precedence, output_on_equal)
      return false unless node.is_a?(Dentaku::AST::Operation)

      target_precedence = node.class.precedence
      target_precedence < precedence || (output_on_equal && target_precedence == precedence)
    end

    def visit_function(node)
      @output << node.name
      @output << "("
      arg_count = node.args.length
      node.args.each_with_index do |a, index|
        a.accept(self)
        @output << ", " unless index >= arg_count - 1
      end
      @output << ")"
    end

    def visit_case(node)
      @output << "CASE "
      node.switch.accept(self)
      node.conditions.each { |c| c.accept(self) }
      node.else && node.else.accept(self)
      @output << " END"
    end

    def visit_switch(node)
      node.node.accept(self)
    end

    def visit_case_conditional(node)
      node.when.accept(self)
      node.then.accept(self)
    end

    def visit_when(node)
      @output << " WHEN "
      node.node.accept(self)
    end

    def visit_then(node)
      @output << " THEN "
      node.node.accept(self)
    end

    def visit_else(node)
      @output << " ELSE "
      node.node.accept(self)
    end

    def visit_negation(node)
      @output << "-"
      @output << "(" unless node.node.is_a? Dentaku::AST::Literal
      node.node.accept(self)
      @output << ")" unless node.node.is_a? Dentaku::AST::Literal
    end

    def visit_access(node)
      node.structure.accept(self)
      @output << "["
      node.index.accept(self)
      @output << "]"
    end

    def visit_literal(node)
      @output << node.quoted
    end

    def visit_identifier(node)
      @output << node.identifier
    end

    def visit_nil(node)
      @output << "NULL"
    end

    def visit_array(node)
      @output << node.value.to_s
    end

    def to_s
      @output
    end
  end
end
