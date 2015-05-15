PuppetLint.new_check(:fileserver) do
  def token_attr(resource, name)
    resource[:tokens].select do |t|
      t.type == :NAME && t.value == name && \
        t.next_code_token && t.next_code_token.type == :FARROW
    end
  end

  def check
    resource_indexes.each do |resource|
      attr = resource[:tokens].select do |t|
        t.prev_code_token && t.prev_code_token.type == :FARROW && t.value =~ %r{^puppet:///}
      end
      next if attr.empty?
      next if resource[:type].value == 'file' and !token_attr(resource, 'recurse').empty? and token_attr(resource, 'recurse')[0].next_code_token.next_code_token.type == :TRUE
      notify :warning, {
        :message  => 'expected file() instead of fileserver',
        :line     => attr[0].line,
        :column   => attr[0].column,
        :token    => attr[0],
        :resource => resource,
      }
    end
  end

  def fix(problem)
    if problem[:resource][:type].value == 'file' or
        problem[:resource][:type].value == 'concat::fragment'
      if problem[:token].type == :SSTRING
        problem[:token].prev_code_token.prev_code_token.value = 'content'
        problem[:token].value.sub!(%r{^puppet:///modules/(.*)}, "file('\\1')")
        problem[:token].type = :NAME
      elsif problem[:token].type == :DQPRE
        problem[:token].prev_code_token.prev_code_token.value = 'content'
        file = PuppetLint::Lexer::Token.new(
          :NAME, 'file',
          problem[:token].line, problem[:token].column+1
        )
        lparen = PuppetLint::Lexer::Token.new(
          :LPAREN, '(',
          problem[:token].line, problem[:token].column+1
        )
        rparen = PuppetLint::Lexer::Token.new(
          :RPAREN, ')',
          problem[:token].line, problem[:token].column+1
        )
        tokens.insert(tokens.index(problem[:token]), file)
        tokens.insert(tokens.index(problem[:token]), lparen)
        problem[:token].value.sub!(%r{^puppet:///modules/}, '')
        t = problem[:token].next_code_token
        while t.type != :DQPOST
          t = t.next_code_token
        end
        tokens.insert(tokens.index(t)+1, rparen)
      else
        raise PuppetLint::NoFix, "Not fixing"
      end
    else
      raise PuppetLint::NoFix, "Not fixing"
    end
  end
end
