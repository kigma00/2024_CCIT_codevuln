document.addEventListener('DOMContentLoaded', function() {
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.onsubmit = function() {
            alert('Form submitted!');
            return true;
        };
    });
});
