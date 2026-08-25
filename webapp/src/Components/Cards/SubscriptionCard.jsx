import { formatDuration, translate } from "@/utils/helper";
import React from "react";
import { BiSolidCheckCircle, BiSolidXCircle } from "react-icons/bi";

const SubscriptionCard = ({
  elem,
  subscribePayment,
  systemsettings,
  allFeatures,
}) => {

  const sortedFeatures = [...allFeatures].sort((a, b) => {
    const aAssigned = elem.features.some((f) => f.id === a.id);
    const bAssigned = elem.features.some((f) => f.id === b.id);
    return bAssigned - aAssigned; // true = 1, false = 0 (assigned comes first)
  });
  return (
    <div
      className="card text-white"
      id={`${elem.is_active ? "current_package_card" : "other_package_card"}`}
    >
      <div id="package_headlines">
        <span
          className={`${
            elem.is_active ? "current_package_card_title" : "other_card_title"
          }`}
        >
          {elem?.name}
        </span>
        <h1 className="card_text">
          {elem.package_type === "paid"
            ? systemsettings?.currency_symbol + elem.price
            : translate("free")}
        </h1>
      </div>

      <div className="subs_other_content">
        <div className="limits">
          <span className="limits_content">
            <span>
              <BiSolidCheckCircle size={20} className=""/>{" "} 
            </span>
            <span>
              {" "}
              {translate("Validity")} {formatDuration(elem.duration)}
            </span>
          </span>

          {allFeatures.map((feature, index) => {
            const assignedFeature = elem.features.find(
              (f) => f.id === feature.id
            );

            return (
              <span className="limits_content" key={index}>
                <span>
                  {assignedFeature ? (
                    <BiSolidCheckCircle size={20} className=""/> // Assigned feature
                  ) : (
                    <BiSolidXCircle size={20} className="not_assigned_feature"/> // Not assigned feature
                  )}
                </span>
                <span>
                  {feature?.name}:{" "}
                  {assignedFeature
                    ? assignedFeature.limit_type === "limited"
                      ? assignedFeature.limit
                      : "Unlimited"
                    : "Not Included"}
                </span>
              </span>
            );
          })}
          {/* {elem.type !== "premium_user" &&
          elem?.advertisement_limit !== "not_available" ? (
            <span className="limits_content">
              <span>
                <BiSolidCheckCircle size={20} />{" "}
              </span>
              <span>
                {" "}
                {translate("Advertisement limit is :")}{" "}
                {elem.advertisement_limit === "unlimited"
                  ? translate("Unlimited")
                  : elem.advertisement_limit}{" "}
              </span>
            </span>
          ) : null}
          {elem.type !== "premium_user" &&
          elem?.property_limit !== "not_available" ? (
            <span className="limits_content">
              <span>
                <BiSolidCheckCircle size={20} />{" "}
              </span>
              <span>
                {" "}
                {translate("Property limit is :")}{" "}
                {elem.property_limit === "unlimited"
                  ? translate("Unlimited")
                  : elem.property_limit}
              </span>
            </span>
          ) : null} */}
        </div>
      </div>

      {elem.is_active ? (
        <div className="spacer"></div>
      ) : (
        <div className="card-footer">
          <div className="subscribe_button">
            <button type="submit" onClick={(e) => subscribePayment(e, elem)}>
              {translate("Subscribe")}
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default SubscriptionCard;
