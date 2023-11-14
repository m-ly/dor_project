require "pg"

class DatabasePersistence
  def data_path
    @db = PG.connect(dbname:'goldline_standard')
  end

  def initialize(logger)
    @db = data_path
    @logger = logger
  end

  def query(statement, *params)
    @logger.info("#{statement}: #{params}")
    @db.exec_params(statement, params)
  end



  # data obtained from JS values
  def create_template(data, creation_date, last_edit_date, creator_id)

    sql = 'INSERT INTO templates (title, creation_date, last_edit_date, creator_id )
           VALUES ($1, $2, $3, $4)
           RETURNING id'

    template_id = query(sql, data['title'], creation_date, last_edit_date, creator_id).values.flatten.first

    content = data['content']

    result = content.each do |element|
      sql2 = 'INSERT INTO evaluation_criteria (heading, template_id, created_on, section_id, subsection_id, element_type)
              VALUES($1, $2, $3, $4, $5, $6)'
      query(sql2, element['heading'], template_id, creation_date, element['sectionId'], element['subSectionId'], element['type'])
    end

    return result.map do |tuple|
      {  template_id: tuple['id'],
         heading: tuple['heading'],
         created_on: tuple['created_on'],
         section_id: tuple['section_id'],
         subsection_id: tuple['subsection_id'],
         element_type: tuple['element_type']
     }
    end
  end

  def load_templates()
    sql = "SELECT * FROM templates"
    query(sql)
  end

  def load_template(id)
    sql = 'SELECT templates.id, templates.title, evaluation_criteria.heading, evaluation_criteria.section_id, evaluation_criteria.subsection_id, evaluation_criteria.element_type, evaluation_criteria.id AS criteria_id
          FROM templates
          INNER JOIN evaluation_criteria ON templates.id = evaluation_criteria.template_id
          WHERE templates.id = $1'
    query(sql,id)
  end

  def delete_template(id)
    sql = 'DELETE FROM templates WHERE id=$1'
    query(sql, id)
  end


  def save_eval(eval_id, criteria_id, rating, content)
    sql = 'INSERT INTO evaluation_responses (eval_id, criteria_id, response_rating, response_value) VALUES($1, $2, $3, $4)'
    query(sql, eval_id,  criteria_id, rating, content)
  end


  def create_eval(title, created_by, trainee_id, template_id, creation_date)
    sql =  'INSERT INTO evaluations (title, created_by, trainee_id, template_id, creation_date)
            VALUES($1, $2, $3, $4, $5)
            RETURNING id'
    result = query(sql, title, created_by, trainee_id, template_id, creation_date)
    result[0]['id']
  end

  ## Users

  def create_user(first_name, last_name, email, password, user_type)
    sql = "INSERT INTO USERS (first_name, last_name, email, password, #{user_type})  VALUES ($1, $2, $3, $4, $5 )"
    query(sql, first_name, last_name, email, password, true )
  end

  def select_users(type=nil)
    if type.nil?
      sql = 'SELECT * FROM users'
    else
      sql = "SELECT * FROM users WHERE #{type} = $1"
    end

    query(sql, true)
  end

  def select_user(id)
    sql = "SELECT * FROM users WHERE id = $1"
    query(sql, id.to_i).tuple_values(0)
  end


  def find_all_usernames
    query('SELECT name from users;')
  end

  def find_user_id(username)
    sql = 'SELECT id FROM users WHERE name = $1;'
    query(sql, username).values.first[0]
  end

  def log_in(name, password)
    sql = 'SELECT * FROM users WHERE name = $1 AND password = $2;'
    query(sql, name, password).first
  end

  def find_user_id(email)
    sql = 'SELECT id FROM users WHERE email = $1;'
    query(sql, email).values.first[0]
  end

  def load_user_data(email)
    sql = 'SELECT * FROM users WHERE email = $1'
    result = query(sql, email)

    result.map do |tuple|
      { user_id: tuple['id'],
        first_name: tuple['first_name'],
        last_name: tuple['_name'],
        password: tuple['password'] }
    end.first
  end

  def load_evals()
    sql = 'SELECT * FROM evaluations'
    result = query(sql)
    result.map do |tuple|
      { id: tuple['id'],
        title:  tuple['title'],
        created_by: tuple['created_by'],
        trainee_id: tuple['trainee_id'],
        creation_date: tuple['creation_date'],
        edit_date: tuple['edit_date'],
        signature: tuple['signature'],
        signature_date: tuple['signature_date'],
        template_id: tuple['template_id']
      }
    end
  end

  def load_eval(id)
    sql = 'SELECT DISTINCT ON (evaluation_criteria.id)
              templates.id as template_id,
              templates.title as template_title,
              evaluation_criteria.heading as heading,
              evaluation_criteria.section_id as section_id,
              evaluation_criteria.subsection_id as subsection_id,
              evaluation_criteria.element_type as element_type,
              evaluation_criteria.id AS criteria_id,
              evaluations.id as evaluation_id,
              evaluation_responses.response_rating as response_rating,
              evaluation_responses.response_value as response_value,
              users.first_name as first_name,
              users.last_name as last_name
          FROM templates
          INNER JOIN evaluation_criteria ON evaluation_criteria.template_id = templates.id
          INNER JOIN evaluations ON evaluations.template_id = templates.id
          INNER JOIN evaluation_responses ON evaluation_responses.criteria_id = evaluation_criteria.id
          INNER JOIN users ON evaluations.trainee_id = users.id
          WHERE evaluation_responses.eval_id = $1
          ORDER BY evaluation_criteria.id'
     result = query(sql, id)

     result.map do |tuple|
      {
        template_id: tuple['template_id'],
        template_title: tuple['template_title'],
        heading: tuple['heading'],
        section_id: tuple['section_id'],
        subsection_id: tuple['subsection_id'],
        element_type: tuple['element_type'],
        criteria_id: tuple['criteria_id'],
        evaluation_id: tuple['evaluation_id'],
        response_rating: tuple['response_rating'],
        response_value: tuple['response_value'],
        first_name: tuple['first_name'],
        last_name: tuple['last_name']
      }
    end
  end
end
