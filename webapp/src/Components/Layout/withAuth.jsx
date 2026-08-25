"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/router";
import { isLogin, translate } from "@/utils/helper";
import Loader from "../Loader/Loader";
import Swal from "sweetalert2";
import { store } from "@/store/store";

const withAuth = (WrappedComponent) => {
  const Wrapper = (props) => {
    const router = useRouter();
    const isLoggedIn = isLogin();

    const userData = store.getState()?.user?.data;
    const hasSubscription = store.getState().Settings?.data?.subscription;
    const isPremiumUser = store.getState().Settings?.data?.is_premium;
    const [isAuthorized, setIsAuthorized] = useState(false);
    const [authChecked, setAuthChecked] = useState(false);

    useEffect(() => {
      const privateRoutes = [
        "/user/advertisement",
        "/user/chat",
        "/user/dashboard",
        "/user/profile",
        "/user/edit-property",
        "/user/edit-project",
        "/user/favorites-properties",
        "/user/personalize-feed",
        "/user/subscription",
        "/user/notifications",
        "/user/transaction-history",
        "/user/interested",
        "/user/projects",
        "/user/verification-form",
        "/my-property",
        "/user-register",
      ];

      // Updated subscription routes to support dynamic slugs
      const subscriptionRoutes = ["/user/properties", "/user/add-project"];

      const premiumUserRoutes = [
        "/project-details", // Base path for dynamic slugs
      ];

      const isPrivateRoute = privateRoutes.includes(router.pathname);

      // Check for subscription routes, including dynamic slugs
      const isSubscriptionRoute = subscriptionRoutes.some((route) =>
        router.pathname.startsWith(route)
      );
      const isPremiumUserRoute = premiumUserRoutes.some((route) =>
        router.pathname.startsWith(route)
      );

      if (isPrivateRoute && !isLoggedIn) {
        router.push("/");
      }
      // else if (isSubscriptionRoute && !hasSubscription) {
      //   Swal.fire({
      //     icon: "error",
      //     title: translate("opps"),
      //     text: translate("youHaveNotSubscribe"),
      //     allowOutsideClick: false,
      //     customClass: {
      //       confirmButton: "Swal-confirm-buttons",
      //     },
      //   }).then((result) => {
      //     if (result.isConfirmed) {
      //       router.push("/subscription-plan"); // Redirect to the subscription page
      //     }
      //   });
      // }
      else if (isPremiumUserRoute && !isPremiumUser) {
        Swal.fire({
          title: translate("opps"),
          text: translate("notPremiumUser"),
          icon: "warning",
          allowOutsideClick: false,
          showCancelButton: false,
          customClass: {
            confirmButton: "Swal-confirm-buttons",
            cancelButton: "Swal-cancel-buttons",
          },
          confirmButtonText: translate("ok"),
        }).then((result) => {
          if (result.isConfirmed) {
            router.push("/");
          }
        });
      } else {
        setIsAuthorized(true);
      }

      setAuthChecked(true);
    }, [userData, router, hasSubscription, isPremiumUser]);

    if (!authChecked) {
      return <Loader />;
    }

    return isAuthorized ? <WrappedComponent {...props} /> : null;
  };

  return Wrapper;
};

export default withAuth;
