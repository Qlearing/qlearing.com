let backbtns = document.getElementsByClassName('goback');

for(let i of backbtns){
    i.addEventListener('click', ()=>{
        if(history.length>2){
            history.back()
        }
        else{
            window.location.href = "main.html"

        }
    })
}