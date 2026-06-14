package listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

import service.RenewalReminderService;

import java.time.Duration;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class SchedulerListener
implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(
            ServletContextEvent sce) {

        System.err.println(
        "SCHEDULER STARTED");

        scheduler =
        Executors.newSingleThreadScheduledExecutor();

        ZoneId zone =
        ZoneId.of("Asia/Kolkata");

        ZonedDateTime now =
        ZonedDateTime.now(zone);

        ZonedDateTime nextRun =
        now.withHour(9)
        .withMinute(0)
        .withSecond(0)
        .withNano(0);

        if(!now.isBefore(nextRun)){

            nextRun =
            nextRun.plusDays(1);
        }

        long initialDelay =
        Duration.between(
        now,
        nextRun
        ).toMillis();

        scheduler.scheduleAtFixedRate(

            () -> {

                try {

                    System.err.println(
                    "Running renewal reminder check...");

                    new RenewalReminderService()
                    .runDailyCheck();

                } catch(Exception e){

                    e.printStackTrace();
                }

            },

            initialDelay,

            1,

            TimeUnit.DAYS
        );
    }

    @Override
    public void contextDestroyed(
            ServletContextEvent sce) {

        if(scheduler != null){

            scheduler.shutdown();
        }
    }
}
