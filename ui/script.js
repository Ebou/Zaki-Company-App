document.addEventListener("DOMContentLoaded", function () {
    async function fetchAndRenderCompanyData() {
        try {
            const companies = await fetchNui('setupApp');
            console.log("Received company data:", JSON.stringify(companies, null, 2)); 

            if (Array.isArray(companies)) {
                renderCompanyButtons(companies);
            } else {
                console.error("Company data is not an array:", companies);
            }
        } catch (error) {
            console.error("Failed to fetch company data:", error);
        }
    }

    function renderCompanyButtons(companies) {
        const companyList = document.getElementById('company-list');
        companyList.innerHTML = '';

        companies.sort((a, b) => {
            if (a.showStatus === false && b.showStatus === true) {
                return -1;
            }
            if (a.showStatus === true && b.showStatus === false) {
                return 1; 
            }
            if (a.showStatus === true && b.showStatus === true) {
                if (a.status === true && b.status === false) {
                    return -1;
                }
                if (a.status === false && b.status === true) {
                    return 1; 
                }
            }
            return 0;
        });

        companies.forEach(company => {
            const statusClass = company.showStatus
                ? (company.status ? 'online' : 'offline')
                : 'blue';

            const companyDiv = document.createElement('div');
            companyDiv.classList.add('company', 'light');

            const logoBox = document.createElement('div');
            logoBox.classList.add('company-image');
            logoBox.innerHTML = `<img src="./assets/${company.img}.png" alt="${company.name}">`;

            const companyName = document.createElement('div');
            companyName.classList.add('company-name');
            companyName.innerHTML = `<h1>${company.name}</h1>`;

            const statusDiv = document.createElement('div');
            statusDiv.classList.add('company-status');
            statusDiv.innerHTML = `<div class="company-status-circle ${statusClass}"></div>`;

            const messageButton = document.createElement('button');
            messageButton.classList.add('send-message-button');
            messageButton.innerHTML = '<i class="fas fa-comments message-icon"></i>'; 
            messageButton.onclick = () => openMessagePopup(company);

            companyDiv.appendChild(logoBox);
            companyDiv.appendChild(companyName);
            companyDiv.appendChild(statusDiv);

            if (company.isWorker) {
                const adButton = document.createElement('button');
                adButton.classList.add('send-ad-button');
                adButton.innerHTML = '<i class="fas fa-bullhorn ad-icon"></i>'; 
                adButton.onclick = () => {
                    setPopUp({
                        title: `Annoncering fra ${company.name}`,
                        description: 'Skriv din annonce nedenfor:',
                        input: {
                            type: 'text',
                            placeholder: 'Indtast din annonce...',
                            value: '',
                            minCharacters: 3,
                            maxCharacters: 100,
                            onChange: (value) => {
                                inputValue = value; 
                                console.log('Annonce input:', value);
                            }
                        },
                        buttons: [
                            {
                                title: 'Annuller',
                                color: 'red',
                                cb: () => {
                                    console.log('Annulleret annoncering');
                                }
                            },
                            {
                                title: 'Send',
                                color: 'blue',
                                cb: () => {
                                    if (inputValue) {
                                        triggerAdEvent(company.job, inputValue);
                                    } else {
                                        console.error('Ingen annonce angivet.');
                                    }
                                }
                            }
                        ]
                    });
                };
                companyDiv.appendChild(adButton);
            } else {
                companyDiv.appendChild(messageButton);
            }

            companyList.appendChild(companyDiv);
        });
    }

    function openMessagePopup(company) {
        let inputValue = ''; 

        setPopUp({
            title: `Send besked til ${company.name}`,
            description: 'Indtast din besked nedenfor',
            input: {
                type: 'text',
                placeholder: 'Skriv din besked her...',
                value: '',
                minCharacters: 3,
                maxCharacters: 20,
                onChange: (value) => {
                    inputValue = value;
                    console.log('Message input:', value);
                }
            },
            buttons: [
                {
                    title: 'Annuller',
                    color: 'red',
                    cb: () => {
                        console.log('Cancelled sending message');
                    }
                },
                {
                    title: 'Send',
                    color: 'blue',
                    cb: () => {
                        if (inputValue) {
                            sendMessageToCompany(company.job, inputValue);
                        } else {
                            console.error('No message entered.');
                        }
                    }
                }
            ]
        });
    }

    function sendMessageToCompany(job, message) {
        fetchNui('sendMessage', { job, message });
        console.log(`Message sent to ${job}: ${message}`);
    }

    function triggerAdEvent(job, message) {
        fetchNui('sendAd', { job, message });
        console.log(`Ad sent to ${job}: ${message}`);
    }

    window.addEventListener("message", (event) => {
        const data = event.data;

        if (data === "componentsLoaded") {
            document.getElementById("phone-wrapper").style.display = "block";
            fetchAndRenderCompanyData();
        }

        if (data && data.action === "refreshCompanies" && data.companies) {
            console.log("Refreshing companies data:", data.companies);
            renderCompanyButtons(data.companies);
        }
    });
});
