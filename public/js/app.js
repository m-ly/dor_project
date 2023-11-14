let criterionForm = `
<label for="criteria">Criterion Text</label>
<input type="text" id="criteria" name="criteria">

<button type="button" id="addCriterion">Add Graded Criterion</button>
<button type="button" id="addSection">Add A new Section</button>
<button type="button" id="addTextBox">Add A Text Box</button>`;


document.addEventListener("DOMContentLoaded", function () {
  const addElement = document.getElementById('newElement');
  const saveTemplate = document.getElementById('submitEvaluation')
  const criteriaFields = document.getElementById('criteriaFields');
  let templateInfo = {content:[]};
  let sectionId = 0;
  let subSectionId = 1;
  


  addElement.addEventListener("click", function () {
    const newField = document.createElement("div")
    if (!document.getElementById('criterionForm')) {
      newField.id = 'criterionForm'
      newField.innerHTML = criterionForm;
      formTemplate.appendChild(newField);
    } else return;
    
    newField.querySelector('#addSection').addEventListener("click", function () {
      const criteriaInput = newField.querySelector('#criteria');
      const criteriaValue = criteriaInput.value;
      const criterion = document.createElement("div");
      sectionId += 1;
      subSectionId = 1;

      criterion.id = `${sectionId}-0`;
      criterion.innerHTML = `<h2>Criterion: ${criteriaValue}</h2>`;
      criteriaFields.appendChild(criterion);
      
      templateInfo['content'].push( 
          {
            'sectionId':sectionId, 
            'subSectionId': 0, 
            'heading': criteriaValue, 
            'type':'sectionHeading',
          });
     
      newField.remove();
      console.log(templateInfo)
    });

    newField.querySelector('#addCriterion').addEventListener("click", function () {
      const criteriaInput = newField.querySelector('#criteria');
      const criteriaValue = criteriaInput.value;
  
      const criterion = document.createElement("div");
      criterion.id = `${sectionId}-${subSectionId}`;
      criterion.innerHTML = `<div>
              <b class="">${criteriaValue}</b>
              <p class="page-header">Daily Rating</p>
              <div class="chart-scale-${sectionId}">
                <div class="scale-buttons">
                  <button class="btn btn-scale btn-scale-asc" data-value="1">1</button>
                  <button class="btn btn-scale btn-scale-asc" data-value="2">2</button>
                  <button class="btn btn-scale btn-scale-asc" data-value="3">3</button>
                  <button class="btn btn-scale btn-scale-asc" data-value="4">4</button>
                  <button class="btn btn-scale btn-scale-asc" data-value="5">5</button>
                  <button class="btn btn-scale btn-scale-asc" data-value="6">6</button>
                  <button class="btn btn-scale btn-scale-asc" data-value="7">7</button>
                  <button class="btn btn-scale btn-scale-asc" data-value="8">8</button>
                  <button class="btn btn-scale btn-scale-asc" data-value="9">9</button>
                  <button class="btn btn-scale btn-scale-asc" data-value="10">10</button>
                </div>
              </div>
            </div>
      
            <div>
              <textarea name="text" rows=15 cols=80 placeholder=""></textarea>
            </div>`
      criteriaFields.appendChild(criterion);
      templateInfo['content'].push( 
        {
            'sectionId':sectionId, 
            'subSectionId':subSectionId, 
            'heading': criteriaValue, 
            'type':'gradedCriteria'
        });
      subSectionId += 1;
      newField.remove();
    });
  
    newField.querySelector('#addTextBox').addEventListener("click", function () {
      const criteriaInput = newField.querySelector('#criteria');
      const criteriaValue = criteriaInput.value;
      const criterion = document.createElement("div");
      criterion.id = `${sectionId}-${subSectionId}`;;
      criterion.innerHTML = `
            <div>
              <b class="">${criteriaValue}</b>
              <div>
                  <textarea name="text" rows=15 cols=80 placeholder=""></textarea>
              </div>
            </div>
          `;
      criteriaFields.appendChild(criterion);
      templateInfo['content'].push( 
         {
            'sectionId':sectionId, 
            'subSectionId':subSectionId, 
            'heading': criteriaValue, 
            'type':'textBox'
         });
      subSectionId += 1;
      newField.remove();
    });
  });

  saveTemplate.addEventListener("click", function() {
    const newField = document.createElement("div")
    if (!document.getElementById('templateName')) {
      newField.id = 'templateName'
      newField.innerHTML = `<form id="templateForm" method="post" action="/forms/create">
                              <label for="criteria">Template Name</label>
                              <input type="text" id="templateName" name="templateName">
                              <button type="button" id="submitEvaluation" value="Save Template">Save Template</button>
                              <button type="button" id="cancel">Cancel</button>
                            </form>`
      formTemplate.appendChild(newField);
    };

    document.getElementById('cancel').addEventListener('click', function () {
      const form = document.getElementById('formTemplate');
      const templateFields = document.getElementById('criteriaFields')
      const templateNameInput = document.getElementById('templateForm');
      
      templateNameInput.value = '';
      templateInfo = {};
      form.removeChild(templateFields);
    })
  

    newField.querySelector("#submitEvaluation").addEventListener('click', function () {
      const templateNameForm = newField.querySelector('#templateName');
      const templateName = templateNameForm.value;
      templateInfo['title'] = templateName;
      console.log(templateInfo)
      fetch('/forms/create', {
        method: 'POST', 
        body: JSON.stringify(templateInfo), 
        headers: {
          'Content-Type': 'application/json'
        }
      }).then(response => {
        if (response.ok) {
          console.log('Data Saved');
          window.location.href = '/forms';
        } else {
          console.error('Error Saving Data')
        }
      }).catch( error => {
        console.error('Error', error)
      })
    })
  });
});