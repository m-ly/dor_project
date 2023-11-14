-- Users Table
CREATE TABLE users (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(250) NOT NULL,
	last_name VARCHAR(250) NOT NULL,
    email VARCHAR(250) NOT NULL,
    password VARCHAR(250) NOT NULL,
    is_admin BOOLEAN DEFAULT False,
    is_supervisor BOOLEAN DEFAULT FALSE,
    is_trainer BOOLEAN DEFAULT FALSE,
    is_trainee BOOLEAN DEFAULT FALSE,
    created_on TIMESTAMP DEFAULT current_timestamp NOT NULL,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true NOT NULL
);

-- Templates Table
CREATE TABLE templates (
    id SERIAL PRIMARY KEY,
    title VARCHAR(250) NOT NULL,
    creation_date TIMESTAMP NOT NULL,
    last_edit_date TIMESTAMP,
    creator_id INT REFERENCES users(id) ON DELETE CASCADE NOT NULL
);

-- Evaluation Criteria Table
CREATE TABLE evaluation_criteria (
    id SERIAL PRIMARY KEY,
    heading VARCHAR(250) NOT NULL,
    criteria_text TEXT,
    template_id INT REFERENCES templates(id) ON DELETE CASCADE NOT NULL,
    number_rank INT.
	created_on TIMESTAMP DEFAULT current_timestamp NOT NULL,
);


-- Evaluations Table
CREATE TABLE evaluations (
    id SERIAL PRIMARY KEY,
    title VARCHAR(250),
    created_by_id INT NOT NULL,
    trainee_id INT NOT NULL,
    creation_date TIMESTAMP NOT NULL,
    edit_date TIMESTAMP,
    signature BOOLEAN,
    signature_date TIMESTAMP,
    template_id INT REFERENCES templates(id) ON DELETE CASCADE NOT NULL
);

-- Response Table 
CREATE TABLE reponses (
  evaluation_id INT REFERENCES evaluations(id) ON DELETE CASCADE NOT NULL,
  criteria_id INT REFERENCES evaluation_criteria(id) ON DELETE CASCADE NOT NULL, 
  response_rating INT,
  response_value TEXT
);