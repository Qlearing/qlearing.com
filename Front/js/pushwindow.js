let isMobMenuOpened = false;
let isLangMenuOpened = false;
let isLoginMenuOpened = false;
let isRegMenuOpened = false;

function pushWindow(type){
    var pushwindowcontainer = document.createElement('div'); // Контейнер
    pushwindowcontainer.className = "pushwindowcontainer";

    var window = document.createElement('div'); // Окно
    window.className = "pushwindow";

    var closewindow = document.createElement('span'); // Кнопка закрытия
    closewindow.className = "material-icons closepushwindow";
    closewindow.innerHTML = "close"

    var windowbg = document.createElement("div"); // Тёмный фон
    windowbg.className = "pushwindowbg"

    window.appendChild(closewindow);
    pushwindowcontainer.appendChild(window)
    pushwindowcontainer.appendChild(windowbg)

    function initpushWindow(){
        document.body.appendChild(pushwindowcontainer);
    }

    // ССЫЛКИ НА main.html!!!

    switch(type){
        case "mobile-menu":
            if(!isMobMenuOpened){
                isMobMenuOpened = true;
                initpushWindow()
                window.className = "pushwindow mobilemenu";
                window.insertAdjacentHTML('afterbegin', `
                <h1>Меню</h1>
                <ul>
                    <li><a href="index.html">Главная</a></li>
                    <li><a class="gotologin">Вход</a></li>
                    <li><a class="gotoreg">Регистрация</a></li>
                    <li><a href="about.html">О нас</a></li>
                    <li><a class="theme-switcher"><span class="material-icons-outlined">
                    dark_mode
                    </span></a></li>
                </ul>
                `)
                window.querySelector(".gotoreg").addEventListener('click', ()=>{
                    closepushWindow("mobile-menu");
                    setTimeout(()=>{
                        pushWindow("regmenu");
                    }, 501)
                })
                window.querySelector(".gotologin").addEventListener('click', ()=>{
                    closepushWindow("mobile-menu");
                    setTimeout(()=>{
                        pushWindow("loginmenu");
                    }, 501)
                })
                windowbg.addEventListener('click',()=>{
                    closepushWindow("mobile-menu");
                })
                closewindow.addEventListener('click', ()=>{
                    closepushWindow("mobile-menu");
                })
                checktheme()
                window.querySelector('.theme-switcher').addEventListener('click',()=>{
                    switchtheme()
                })
            }
            break;
        case "lang-menu":
            if(!isLangMenuOpened){
                isLangMenuOpened = true;
                initpushWindow()
                window.className = "pushwindow langmenu";
                window.insertAdjacentHTML('afterbegin', `
                <h1>Язык</h1>
                <ul>
                    <li><a>Русский</a></li>
                    <li><a>English</a></li>
                    <li><a>Українська мова</a></li>
                    <li><a>Беларуская мова</a></li>
                </ul>
                `)
                windowbg.addEventListener('click',()=>{
                    closepushWindow("lang-menu");
                })
                closewindow.addEventListener('click', ()=>{
                    closepushWindow("lang-menu");
                })
            }
            break;
        case "loginmenu":
            if(!isLoginMenuOpened){
                isLoginMenuOpened = true;
                initpushWindow()
                window.className = "pushwindow loginmenu";
                window.insertAdjacentHTML('afterbegin', `
                <h1>Вход</h1>
                <ul>
                <form>
                    <input class="input" type="text" placeholder="Почта/номер">
                    <input class="input" type="password" placeholder="Пароль">
                    <span class="forgot-password">Забыли пароль?</span>
                    <div class="footer">
                    <div class="login-types">
                        <img src="img/social/telegram.png">
                    </div>
                    <div class="btns-block">
                        <a class="btn-accolor gotoreg">Регистрация</a>
                        <a href="main.html"><input type="button" class="btn-border" value="Войти"> </a>
                    </div>
                </div>    
                <form>
                </ul>
                `)
                window.querySelector(".gotoreg").addEventListener('click', ()=>{
                    closepushWindow("login-menu");
                    setTimeout(()=>{
                        pushWindow("regmenu");
                    }, 501)
                })
                windowbg.addEventListener('click',()=>{
                    closepushWindow("login-menu");
                })
                closewindow.addEventListener('click', ()=>{
                    closepushWindow("login-menu");
                })
            }
            break;
        case "regmenu":
            if(!isRegMenuOpened){
                isRegMenuOpened = true;
                initpushWindow()
                window.className = "pushwindow regmenu";
                window.insertAdjacentHTML('afterbegin', `
                <h1>Регистрация</h1>
                <ul>
                <form>
                    <input class="input" type="text" placeholder="Почта">
                    <input class="input" type="text" placeholder="Номер">

                    <input class="input" type="password" placeholder="Пароль">
                    <input class="input" type="password" placeholder="Повторите пароль">

                    <div class="footer">
                    <div class="login-types">
                        <img src="img/social/telegram.png">
                    </div>
                    <div class="btns-block">
                        <a class="btn-accolor gotologin">Вход</a>
                        <a href="main.html"><input type="button" class="btn-border" value="Готово"></a> 
                    </div>
                </div>    
                <form>
                </ul>
                `)
                window.querySelector(".gotologin").addEventListener('click', ()=>{
                    closepushWindow("reg-menu");
                    setTimeout(()=>{
                        pushWindow("loginmenu");
                    }, 501)
                })
                windowbg.addEventListener('click',()=>{
                    closepushWindow("reg-menu");
                })
                closewindow.addEventListener('click', ()=>{
                    closepushWindow("reg-menu");
                })
            }
            break;
    }
    function closepushWindow(type){
        switch(type){
            case "mobile-menu":
                isMobMenuOpened = false;
                break;
            case "lang-menu":
                isLangMenuOpened = false;
                break;
            case "login-menu":
                isLoginMenuOpened = false;
                break;
            case "reg-menu":
                isRegMenuOpened = false;
                break;  
        }
        window.classList.add('hiding');
        windowbg.classList.add('hiding')
        setTimeout(()=>{
            pushwindowcontainer.remove();
        }, 500)
    }
}