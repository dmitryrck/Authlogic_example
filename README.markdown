O Authlogic é um plugin/gem para executar tarefas de autenticação com muitos recursos: criptografia de senhas, logout por inatividade, dentre outros.

Primeiro instale o Authlogic:

Depois configure o seu arquivo config/environment.rb conforme abaixo, na linha 11:

    RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

    require File.join(File.dirname(__FILE__), 'boot')

    Rails::Initializer.run do |config|
      # Specify gems that this application depends on and have them installed with rake gems:install
      # config.gem "bj"
      # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
      # config.gem "sqlite3-ruby", :lib => "sqlite3"
      # config.gem "aws-s3", :lib => "aws/s3"
      config.gem "authlogic"

      config.time_zone = 'UTC'
    end

Enxuguei o arquivo para que ficasse somente com o necessário e os exemplos de configurações de gems, que, como você pode ver, pode-se também configurar por versões.

Com a configuração feita vamos gerar todos os models, controllers e views necessárias.

Vamos primeiro criar:

    cpd102[pts/0]% script/generate session user_session
          exists  app/models/
          create  app/models/user_session.rb

Por fim o arquivo deve-se parecer com:

    class UserSession < Authlogic::Session::Base
    end

Vamos criar o controller:

    cpd102[pts/0]% ./script/generate controller user_sessions
          exists  app/controllers/
          exists  app/helpers/
          create  app/views/user_sessions
          exists  test/functional/
          create  test/unit/helpers/
          create  app/controllers/user_sessions_controller.rb
          create  test/functional/user_sessions_controller_test.rb
          create  app/helpers/user_sessions_helper.rb
          create  test/unit/helpers/user_sessions_helper_test.rb

Adicione o conteúdo abaixo ao arquivo app/controllers/user_sessions_controller.rb, ele deve ter somente a primeira e última linha:

    class UserSessionsController < ApplicationController
      skip_before_filter :require_user, :check_role

      def new
        @user_session = UserSession.new
      end

      def create
        @user_session = UserSession.new(params[:user_session])
        if @user_session.save
          flash[:notice] = nil
          redirect_back_or_default users_url
        else
          flash[:notice] = "Login failed"
          render :action => :new
        end
      end
    
      def destroy
        current_user_session.destroy
        redirect_back_or_default root_url
      end
    end

E para completar ao app/controllers/application_controller.rb:

    # Filters added to this controller apply to all controllers in the application.
    # Likewise, all the methods added will be available for all controllers.

    class ApplicationController < ActionController::Base
      before_filter :require_user

      filter_parameter_logging :password, :password_confirmation
      helper_method :current_user_session, :current_user

      private
      def current_user_session
        return @current_user_session if defined?(@current_user_session)
        @current_user_session = UserSession.find
      end

      def current_user
        return @current_user if defined?(@current_user)
        @current_user = current_user_session && current_user_session.user
      end

      def require_user
        unless current_user
          store_location
          redirect_to new_user_session_url
          return false
        end
      end

      def store_location
        session[:return_to] = request.request_uri
      end

      def redirect_back_or_default(default)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
      end

      helper :all # include all helpers, all the time
      protect_from_forgery # See ActionController::RequestForgeryProtection for details

      # Scrub sensitive parameters from your log
      # filter_parameter_logging :password
    end

Somente da linha 5 a 36 foi adicionado.


A única view necessária é a de login, vamos criar então o arquivo app/views/user_sessions/new.html.erb:

    <div class="loginbox">
      <h2>Login</h2>
      <% form_for @user_session, :url => user_session_path do |f| %>

        <p><%= f.label :login %><br />
          <%= f.text_field :login, :size => 20 %></p>
        <p><%= f.label :password %><br />
          <%= f.password_field :password, :size => 20 %></p>

        <%= f.submit "logar" %>
      <% end %>
    </div>

E por fim o gerenciamento dos usuários com o comando abaixo:

    ./script/generate scaffold user login:string name:string email:string crypted_password:string password_salt:string persistence_token:string login_count:integer last_request_at:datetime last_login_at:datetime current_login_at:datetime last_login_ip:string current_login_ip:string active:boolean

    cpd102[pts/0]% ./script/generate scaffold user \
    > login:string \
    > name:string \
    > email:string \
    > crypted_password:string \
    > password_salt:string \
    > persistence_token:string \
    > login_count:integer \
    > last_request_at:datetime \
    > last_login_at:datetime \
    > current_login_at:datetime \
    > last_login_ip:string \
    > current_login_ip:string \
    > active:boolean
          exists  app/models/
          exists  app/controllers/
          exists  app/helpers/
          create  app/views/users
          exists  app/views/layouts/
          exists  test/functional/
          exists  test/unit/
          exists  test/unit/helpers/
          exists  public/stylesheets/
          create  app/views/users/index.html.erb
          create  app/views/users/show.html.erb
          create  app/views/users/new.html.erb
          create  app/views/users/edit.html.erb
          create  app/views/layouts/users.html.erb
          create  public/stylesheets/scaffold.css
          create  app/controllers/users_controller.rb
          create  test/functional/users_controller_test.rb
          create  app/helpers/users_helper.rb
          create  test/unit/helpers/users_helper_test.rb
           route  map.resources :users
      dependency  model
          exists    app/models/
          exists    test/unit/
          exists    test/fixtures/
          create    app/models/user.rb
          create    test/unit/user_test.rb
          create    test/fixtures/users.yml
          create    db/migrate
          create    db/migrate/20090724124349_create_users.rb

Vou traduzir de forma rápida a documentação de como ficaria a migração:

    t.string    :login,               :null => false                # opcional, pode-se usar e-mail ou ambos
    t.string    :crypted_password,    :null => false                # requerido
    t.string    :password_salt,       :null => false                # opcional, mas extremamente recomendado
    t.string    :persistence_token,   :null => false                # requerido
    t.string    :single_access_token, :null => false                # opcional, veja Authlogic::Session::Params
    t.string    :perishable_token,    :null => false                # opcional, veja Authlogic::Session::Perishability
    t.integer   :login_count,         :null => false, :default => 0 # opcional, veja Authlogic::Session::MagicColumns
    t.datetime  :last_request_at                                    # opcional, veja Authlogic::Session::MagicColumns
    t.datetime  :current_login_at                                   # opcional, veja Authlogic::Session::MagicColumns
    t.datetime  :last_login_at                                      # opcional, veja Authlogic::Session::MagicColumns
    t.string    :current_login_ip                                   # opcional, veja Authlogic::Session::MagicColumns
    t.string    :last_login_ip                                      # opcional, veja Authlogic::Session::MagicColumns

O que estivem como ``Authlogic::Session::MagicColumns`` são colunas "mágicas" que são alteradas conforme o uso.

Eu costumo manter o ``active:boolean`` pois se estiver como falso para um usuário este usuário não vai poder logar.

Para que seja possível o login o model de usuários deve conter um conteúdo semelhante a:

    class User < ActiveRecord::Base
      acts_as_authentic do |auth|
        auth.logged_in_timeout = 60.minutes
      end
    end

Após criar o scaffold do usuário, vamos editar as views de edição para solicitar apenas as informações como login, senha, confirmação de senha e ativo.

Arquivo app/views/users/new.html.erb:

    <% form_for(@user) do |f| %>
      <%= f.error_messages %>

      <%= render :partial => "write", :locals => { :f => f } %>

      <p>
        <%= f.submit "Criar" %>
      </p>
    <% end %>

Arquivo app/views/users/edit.html.erb de forma semelhante:

    <% form_for(@user) do |f| %>
      <%= f.error_messages %>

      <%= render :partial => "write", :locals => { :f => f } %>

      <p>
        <%= f.submit "Atualizar" %>
      </p>
    <% end %>

E por fim a partial app/views/users/_write.html.erb:

    <p>
      <%= f.label :login %><br />
      <%= f.text_field :login %>
    </p>
    <p>
      <%= f.label :name %><br />
      <%= f.text_field :name %>
    </p>
    <p>
      <%= f.label :email %><br />
      <%= f.text_field :email %>
    </p>
    <p>
      <%= f.label :password %><br />
      <%= f.text_field :password %>
    </p>
    <p>
      <%= f.label :password_confirmation %><br />
      <%= f.text_field :password_confirmation %>
    </p>
    <p>
      <%= f.label :active %><br />
      <%= f.check_box :active %>
    </p>

Veja que para criar e editar os usuários apenas estes campos são necessários, pois campos como login_count são modificados pelo authlogic de forma dinâmica.

Com as views de usuários pronta vamos migrar o banco e adicionar nosso primeiro usuário

    ubuntu[pts/2]% rake db:migrate
    (in /home/dmitry/Projects/Authlogic_example)
    ==  CreateUsers: migrating ====================================================
    -- create_table(:users)
       -> 0.0045s
    ==  CreateUsers: migrated (0.0046s) ===========================================

E antes de iniciar o servidor para testar vamos adicionar as seguintes rotas:

    ActionController::Routing::Routes.draw do |map|
      map.resources :users
    
      map.resource :user_session
      map.login '/login', :controller => 'user_sessions', :action => 'new'
      map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
    
      map.connect ':controller/:action/:id'
      map.connect ':controller/:action/:id.:format'
    end

E criar o primeiro usuário.

    cpd102[pts/0]% ./script/console
    Loading development environment (Rails 2.3.3)
    >> User.create!(:login => "usuario", :name => "Primeiro Usuario", :email => "mail@valido.com", :password => "senha", :password_confirmation => "senha", :active => true)
=> #<User id: 1, login: "usuario", name: "Primeiro Usuario", email: "mail@valido.com", crypted_password: "0ab834ca00acc9ec3ff90d3c1fb83ff753a8b504f619c89d7f6...", password_salt: "qBCd39TzjTInLtl4sZsS", persistence_token: "816d2cb216602fd78dbae61dc4963b79e55a034fac32427bca7...", login_count: nil, last_request_at: nil, last_login_at: nil, current_login_at: nil, last_login_ip: nil, current_login_ip: nil, active: nil, created_at: "2009-07-24 12:55:58", updated_at: "2009-07-24 12:55:58">


Conforme fiz guardei o projeto e coloquei em [http://github.com/dmitrynix/Authlogic_example](http://github.com/dmitrynix/Authlogic_example).
