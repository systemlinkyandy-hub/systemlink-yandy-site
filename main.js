/*
  Design philosophy: Clinical Data Craft
  操作は静かで予測可能にする。短い状態変化のみを使い、すべての主要機能はJavaScriptなしでも到達可能にする。
*/

document.documentElement.classList.add("js-ready");

const header = document.querySelector("[data-header]");
const menuButton = document.querySelector("[data-menu-button]");
const nav = document.querySelector("[data-nav]");
const navLinks = nav ? [...nav.querySelectorAll("a")] : [];

const closeMenu = () => {
  if (!menuButton || !nav || !header) return;
  menuButton.setAttribute("aria-expanded", "false");
  nav.classList.remove("is-open");
  header.classList.remove("is-open");
  document.body.classList.remove("menu-open");
};

if (menuButton && nav && header) {
  menuButton.addEventListener("click", () => {
    const willOpen = menuButton.getAttribute("aria-expanded") !== "true";
    menuButton.setAttribute("aria-expanded", String(willOpen));
    nav.classList.toggle("is-open", willOpen);
    header.classList.toggle("is-open", willOpen);
    document.body.classList.toggle("menu-open", willOpen);
  });

  navLinks.forEach((link) => link.addEventListener("click", closeMenu));

  window.addEventListener("resize", () => {
    if (window.innerWidth >= 900) closeMenu();
  });
}

const updateHeader = () => {
  header?.classList.toggle("is-scrolled", window.scrollY > 18);
};
updateHeader();
window.addEventListener("scroll", updateHeader, { passive: true });

const revealItems = document.querySelectorAll(".reveal");
if ("IntersectionObserver" in window) {
  const revealObserver = new IntersectionObserver(
    (entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      });
    },
    { rootMargin: "0px 0px -8%", threshold: 0.08 },
  );
  revealItems.forEach((item) => revealObserver.observe(item));
} else {
  revealItems.forEach((item) => item.classList.add("is-visible"));
}

const currentYear = document.querySelector("[data-year]");
if (currentYear) currentYear.textContent = String(new Date().getFullYear());

