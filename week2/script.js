function calculateResult(event) {

    event.preventDefault();

    let EnglishMarks = Number(document.getElementById("EngMarks").value);
    let NepaliMarks = Number(document.getElementById("NepMarks").value);
    let ScienceMarks = Number(document.getElementById("SciMarks").value);
    let MathsMarks = Number(document.getElementById("MathsMarks").value);
    let OptMathsMarks = Number(document.getElementById("OptMathsMarks").value);
    let SocMarks = Number(document.getElementById("SocMarks").value);
    let CompSciMarks = Number(document.getElementById("CompSciMarks").value);
    let HealthMarks = Number(document.getElementById("HealthMarks").value);

    let totalMarks =
        EnglishMarks +
        NepaliMarks +
        ScienceMarks +
        MathsMarks +
        OptMathsMarks +
        SocMarks +
        CompSciMarks +
        HealthMarks;

    let result = document.getElementById("result");

    if (totalMarks > 700) {
        result.style.color = "#06963b";
        result.innerText =
            `Total Marks: ${totalMarks} | Distinction`;
    }

    else if (totalMarks > 600) {
        result.style.color = "#57aa75";
        result.innerText =
            `Total Marks: ${totalMarks} | First Division`;
    }

    else if (totalMarks >= 500) {
        result.style.color = "#38bdf8";
        result.innerText =
            `Total Marks: ${totalMarks} | Second Division`;
    }

    else if (totalMarks >= 400) {
        result.style.color = "#facc15";
        result.innerText =
            `Total Marks: ${totalMarks} | Third Division`;
    }

    else {
        result.style.color = "#ef4444";
        result.innerText =
            `Total Marks: ${totalMarks} | Fail`;
    }

}