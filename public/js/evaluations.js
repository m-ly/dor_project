document.addEventListener("DOMContentLoaded", function () {
  let formValues = {};
  const buttonForms = document.querySelectorAll('[id^=chart-scale-]');
  let templateIdContainer = document.getElementById('templateIdContainer')
  console.log(templateIdContainer)
  let formId = templateIdContainer.dataset.formId
  console.log(formId)
 
 

  buttonForms.forEach((buttonForm) => {
    const buttons = buttonForm.querySelectorAll('[class^=btn-scale]');
    let lastClickedButton = null;

    buttons.forEach((button) => {
      button.addEventListener('click', function (buttonClick) {
          buttonClick.preventDefault();
          if (lastClickedButton) {
                  lastClickedButton.style.backgroundColor = "";
          }

          button.style.backgroundColor = "lightblue";
          lastClickedButton = button; 
    
          const value = buttonClick.target.getAttribute('data-value');
          const greatGrandparentNode = buttonClick.target.parentElement.parentElement.parentElement;
          const sectionId = greatGrandparentNode.getAttribute('id');
          
          if (formValues[sectionId] && formValues[sectionId]['numberRating']) {
              formValues[sectionId]["numberRating"] = value;
          } else {
              formValues[sectionId] = {"numberRating": value};
          }
      });
  });

  })
  
  const textBoxes = document.querySelectorAll('[id^=text-]');

  function saveTextValues() {
      textBoxes.forEach((textBox) => {
          const sectionId = textBox.id.split('-')[1];
    
          if (formValues[sectionId]) {
            formValues[sectionId]['textContent'] = textBox.value
          } else {
            formValues[sectionId] = { 'textContent': textBox.value };
          }
          
      });
  }

  document.getElementById("saveEval").addEventListener('click', function (event) {
    event.preventDefault();
    let traineeId = document.getElementById('trainee-name')
    formValues['traineeId'] = traineeId.value
      textBoxes.forEach( (box, index) => {
        let id = box.id;
        saveTextValues(formValues, index, id, box.value)
      })
      fetch('/evals/'+ formId +'/save', {
          method: 'POST', 
          body: JSON.stringify(formValues), 
          headers: {
              'Content-Type': 'application/json'
          }
      }).then(response => {
          if (response.ok) {
              console.log('Data Saved');
              console.log(formValues)
              window.location.href = '/'
          } else {
              console.error('Error Saving Data');
          }
      }).catch( error => {
          console.error('Error', error);
      });
  });
});