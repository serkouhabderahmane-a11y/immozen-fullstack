"use client";
import React, { useState, useEffect } from "react";
// Logo is served from public folder
const immozenLogo = "/images/logo/immozen-logo.svg";
import { RiArrowRightSLine, RiUserSmileLine } from "react-icons/ri";
import { CloseButton, Dropdown } from "react-bootstrap";
import Offcanvas from "react-bootstrap/Offcanvas";
import Link from "next/link";
import { FiPlusCircle } from "react-icons/fi";
import LoginModal from "../LoginModal/LoginModal";
import AreaConverter from "../AreaConverter/AreaConverter";
import { GiHamburgerMenu } from "react-icons/gi";
import { useSelector } from "react-redux";
import { logoutSuccess, userSignUpData } from "@/store/reducer/authSlice";

import "react-confirm-alert/src/react-confirm-alert.css";
import { toast } from "react-hot-toast";
import { Fcmtoken, settingsData } from "@/store/reducer/settingsSlice";
import { languageLoaded, setLanguage } from "@/store/reducer/languageSlice";
import {
  handlePackageCheck,
  placeholderImage,
  translate,
  truncate,
} from "@/utils/helper";
import { store } from "@/store/store";
import Swal from "sweetalert2";
import { useRouter } from "next/router";
import Image from "next/image";
import { silderCacheData, sliderLength } from "@/store/reducer/momentSlice";
import FirebaseData from "@/utils/Firebase";
import { beforeLogoutApi, GetLimitsApi } from "@/store/actions/campaign";
import MobileOffcanvas from "./MobileOffcanvas";
import { PackageTypes } from "@/utils/checkPackages/packageTypes";

const Nav = () => {
  const router = useRouter();
  const language = store.getState().Language.languages;
  const { signOut } = FirebaseData();

  const isHomePage = router.pathname === "/";
  const user_register = router.pathname === "/user-register";
  const signupData = useSelector(userSignUpData);
  const sliderdata = useSelector(sliderLength);
  const settingData = useSelector(settingsData);
  const FcmToken = useSelector(Fcmtoken);
  const LanguageList = settingData && settingData.languages;
  const systemDefaultLanguageCode = settingData?.default_language;
  const [showModal, setShowModal] = useState(false);
  const [areaconverterModal, setAreaConverterModal] = useState(false);
  const [selectedLanguage, setSelectedLanguage] = useState();
  const [defaultlang, setDefaultlang] = useState(language.name);
  const [show, setShow] = useState(false);
  const [headerTop, setHeaderTop] = useState(0);
  const [scroll, setScroll] = useState(0);
  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  useEffect(() => {
    if (language && language.rtl === 1) {
      document.documentElement.dir = "rtl";
    } else {
      document.documentElement.dir = "ltr";
    }
  }, [language]);


  useEffect(() => {
    const header = document.querySelector(".header");
    setHeaderTop(header.offsetTop);
    window.addEventListener("scroll", handleScroll);
    return () => {
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);

  useEffect(() => {
    if (!language || Object.keys(language).length === 0) {
      languageLoaded(
        systemDefaultLanguageCode,
        "1",
        (response) => {
          const currentLang = response && response.data.name;

          // Dispatch the setLanguage action to update the selected language in Redux
          store.dispatch(setLanguage(currentLang));
          setSelectedLanguage(currentLang);
          setDefaultlang(currentLang);
        },
        (error) => {
          console.log(error);
        }
      );
    }
  }, [language]);
  const handleLanguageChange = (languageCode) => {
    languageLoaded(
      languageCode,
      "1",
      (response) => {
        const currentLang = response && response.data.name;
        setSelectedLanguage(currentLang);

        // Dispatch the setLanguage action to update the selected language in Redux
        store.dispatch(setLanguage(currentLang));
      },
      (error) => {
        toast.error(error);
        console.log(error);
      }
    );
  };
  useEffect(() => {}, [selectedLanguage, language, defaultlang]);

  const handleScroll = () => {
    setScroll(window.scrollY);
  };

  const handleOpenModal = () => {
    setShow(false);
    setShowModal(true);
  };

  const handleCloseModal = () => {
    setShowModal(false);
  };
  const handleOpenAcModal = () => {
    setShow(false);
    setAreaConverterModal(true);
  };
  const handleCloseAcModal = () => {
    setAreaConverterModal(false);
  };

  const handleShowDashboard = () => {
    router.push("/user/dashboard"); // Use an absolute path here
  };

  const handleLogout = () => {
    handleClose();
    Swal.fire({
      title: translate("areYouSure"),
      text: translate("youNotAbelToRevertThis"),
      icon: "warning",
      showCancelButton: true,
      customClass: {
        confirmButton: "Swal-confirm-buttons",
        cancelButton: "Swal-cancel-buttons",
      },
      confirmButtonText: translate("yesLogout"),
    }).then((result) => {
      if (result.isConfirmed) {
        try {
          beforeLogoutApi({
            fcm_id: FcmToken,
            onSuccess: (res) => {
              // Perform the logout action
              logoutSuccess();
              signOut();

              toast.success(translate("logoutSuccess"));
            },
            onError: (err) => {
              console.log(err);
            },
          });
        } catch (error) {
          console.log(error);
        }
      } else {
        toast.error(translate("logoutcancel"));
      }
    });
  };

  const CheckActiveUserAccount = () => {
    if (settingData?.is_active === false) {
      Swal.fire({
        title: translate("opps"),
        text: "Your account has been deactivated by the admin. Please contact them.",
        icon: "warning",
        allowOutsideClick: false,
        showCancelButton: false,
        customClass: {
          confirmButton: "Swal-confirm-buttons",
          cancelButton: "Swal-cancel-buttons",
        },
        confirmButtonText: translate("logout"),
      }).then((result) => {
        if (result.isConfirmed) {
          logoutSuccess();
          signOut();
          router.push("/contact-us");
        }
      });
    }
  };
  useEffect(() => {
    CheckActiveUserAccount();
  }, [settingData?.is_active]);

  return (
    <>
      <header>
        <nav
          className={`navbar header navbar-expand-lg navbar-light ${
            scroll > headerTop ||
            (isHomePage && (!sliderdata || sliderdata.length === 0))
              ? "is-sticky"
              : ""
          }`}
        >
          <div className="container">
            <div className="left-side">
              <Link className="navbar-brand" href="/">
                <Image
                  loading="lazy"
                  src={settingData?.web_logo ? settingData?.web_logo : immozenLogo}
                  alt="Immozen"
                  className="logo logo_filter"
                  width={0}
                  height={76}
                  style={{ width: "auto" }}
                  onError={placeholderImage}
                />
              </Link>
              <span onClick={handleShow} id="hamburg">
                <GiHamburgerMenu size={36} />
              </span>
            </div>

            <div className="center-side">
              <div
                className="collapse navbar-collapse"
                id="navbarSupportedContent"
              >
                <ul className="navbar-nav me-auto mb-2 mb-lg-0">
                  <li className="nav-item">
                    <Link
                      className="nav-link active"
                      aria-current="page"
                      href="/"
                    >
                      {translate("home")}
                    </Link>
                  </li>
                  <Dropdown>
                    <Dropdown.Toggle id="dropdown-basic">
                      {translate("properties")}
                    </Dropdown.Toggle>

                    <Dropdown.Menu>
                      <Dropdown.Item>
                        <Link href="/properties/all-properties/">
                          <span className="links">
                            {translate("allProperties")}
                          </span>
                        </Link>
                      </Dropdown.Item>
                      <Dropdown.Item>
                        <Link href="/featured-properties">
                          <span className="links">
                            {translate("featuredProp")}
                          </span>
                        </Link>
                      </Dropdown.Item>
                      <Dropdown.Item>
                        {" "}
                        <Link href="/most-viewed-properties">
                          <span className="links">
                            {translate("mostViewedProp")}
                          </span>
                        </Link>
                      </Dropdown.Item>
                      <Dropdown.Item>
                        {" "}
                        <Link href="/properties-nearby-city">
                          <span className="links">
                            {translate("nearbyCities")}
                          </span>
                        </Link>
                      </Dropdown.Item>
                      <Dropdown.Item>
                        <Link href="/most-favorite-properties">
                          <span className="links">
                            {translate("mostFavProp")}
                          </span>
                        </Link>
                      </Dropdown.Item>
                      {/* <Dropdown.Item><Link href="/listby-agents"></Link>{translate("listByAgents")}</Dropdown.Item> */}
                    </Dropdown.Menu>
                  </Dropdown>
                  <Dropdown>
                    <Dropdown.Toggle id="dropdown-basic">
                      {translate("pages")}
                    </Dropdown.Toggle>

                    <Dropdown.Menu>
                      <Dropdown.Item>
                        <Link href="/subscription-plan">
                          <span className="links">
                            {translate("subscriptionPlan")}
                          </span>
                        </Link>
                      </Dropdown.Item>
                      <Dropdown.Item>
                        {" "}
                        <Link href="/articles">
                          <span className="links">{translate("articles")}</span>
                        </Link>
                      </Dropdown.Item>
                      <Dropdown.Item>
                        {" "}
                        <Link href="/faqs">
                          <span className="links">{translate("faqs")}</span>
                        </Link>
                      </Dropdown.Item>
                      <Dropdown.Item onClick={handleOpenAcModal}>
                        <span className="perent_link">
                          <span className="links">
                            {translate("areaConverter")}
                          </span>
                        </span>
                      </Dropdown.Item>
                      <Dropdown.Item>
                        <Link href="/terms-and-condition">
                          <span className="links">
                            {translate("terms&condition")}
                          </span>
                        </Link>
                      </Dropdown.Item>
                      <Dropdown.Item>
                        {" "}
                        <Link href="/privacy-policy">
                          <span className="links">
                            {translate("privacyPolicy")}
                          </span>
                        </Link>
                      </Dropdown.Item>
                    </Dropdown.Menu>
                  </Dropdown>
                  <Link href="/contact-us" id="a-tags-link">
                    <li className="nav-item nav-link">
                      {translate("contactUs")}
                    </li>
                  </Link>

                  <Link className="nav-link" href="/about-us">
                    <li className="nav-item">{translate("aboutUs")}</li>
                  </Link>
                </ul>
              </div>
            </div>
            <div className="right-side">
              <div
                className="collapse navbar-collapse"
                id="navbarSupportedContent"
              >
                <ul className="navbar-nav ml-auto">
                  <Dropdown>
                    <Dropdown.Toggle id="dropdown-basic">
                      {" "}
                      {selectedLanguage ? selectedLanguage : defaultlang}
                    </Dropdown.Toggle>
                    <Dropdown.Menu>
                      {LanguageList &&
                        LanguageList.map((ele, index) => (
                          <Dropdown.Item
                            key={index}
                            onClick={() => handleLanguageChange(ele.code)}
                          >
                            <span className="perent_link">
                              <span className="links">{ele.name}</span>
                            </span>
                          </Dropdown.Item>
                        ))}
                    </Dropdown.Menu>
                  </Dropdown>
                  <li className="nav-item">
                    {
                      // Check if signupData.data is null
                      signupData?.data === null ? (
                        <a
                          className="nav-link"
                          to="/"
                          onClick={handleOpenModal}
                        >
                          <RiUserSmileLine size={20} className="icon" />
                          {translate("login&Register")}
                        </a>
                      ) : signupData?.data?.data.name || signupData?.data?.data.email || signupData?.data?.data.mobile ? (
                        <Dropdown>
                          <Dropdown.Toggle id="dropdown-basic01">
                            <RiUserSmileLine size={20} className="icon01" />
                            {signupData.data.data.name ? truncate(signupData.data.data.name, 15): translate("welcmGuest")}
                          </Dropdown.Toggle>

                          <Dropdown.Menu id="language">
                            <Dropdown.Item onClick={handleShowDashboard}>
                              <span className="perent_link">
                                <span className="links">
                                  {translate("dashboard")}
                                </span>
                              </span>
                            </Dropdown.Item>
                            <Dropdown.Item onClick={handleLogout}>
                              <span className="perent_link">
                                <span className="links">
                                  {translate("logout")}
                                </span>
                              </span>
                            </Dropdown.Item>
                          </Dropdown.Menu>
                        </Dropdown>
                      ) : null
                    }
                  </li>
                  {signupData?.data?.data.name && settingData && (
                    <li className="nav-item">
                      <button
                        className="btn"
                        id="addbutton"
                        onClick={(e) => handlePackageCheck(e, PackageTypes.PROPERTY_LIST, router)}
                      >
                        <FiPlusCircle
                          size={20}
                          className="mx-2 add-nav-button"
                        />
                        {translate("addProp")}
                      </button>
                    </li>
                  )}
                </ul>
              </div>
            </div>
          </div>
        </nav>
      </header>

      <div>
        <MobileOffcanvas
          show={show}
          handleClose={handleClose}
          settingData={settingData}
          signupData={signupData}
          translate={translate}
          handleOpenModal={handleOpenModal}
          handleShowDashboard={handleShowDashboard}
          handleLogout={handleLogout}
          handleLanguageChange={handleLanguageChange}
          LanguageList={LanguageList}
          defaultlang={defaultlang}
          handleOpenAcModal={handleOpenAcModal}
          selectedLanguage={selectedLanguage}
          language={language}
        />
      </div>
      {showModal && (
        <LoginModal isOpen={showModal} onClose={handleCloseModal} />
      )}

      <AreaConverter isOpen={areaconverterModal} onClose={handleCloseAcModal} />
    </>
  );
};

export default Nav;
